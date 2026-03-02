# tools/audit_tidyverse_deprecations.R
# Static audit for tidyverse lifecycle/deprecation patterns in project code
# - Does NOT execute project code (so it won't trigger deprecation warnings)
# - Scans source files with regex + a few heuristics
# - Writes CSV outputs for manual review
#
# Usage:
# source("tools/audit_tidyverse_deprecations.R")
# res <- audit_tidyverse_deprecations(
#   root = "R",
#   output_csv = "tools/tidyverse_deprecation_audit.csv"
# )

# ============================================================
# Utilities
# ============================================================

`%||%` <- function(x, y) if (is.null(x)) y else x

norm_path <- function(x) gsub("\\\\", "/", x)

# Use PCRE here to avoid TRE/POSIX regex errors with {} in char classes
escape_regex_literal <- function(x) {
  gsub("([][{}()+*^$|\\\\?.-])", "\\\\\\1", x, perl = TRUE)
}

safe_read_text <- function(path) {
  txt <- tryCatch(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(e) NULL
  )
  if (is.null(txt)) {
    txt <- tryCatch(
      readLines(path, warn = FALSE),
      error = function(e) character(0)
    )
  }
  paste(txt, collapse = "\n")
}

line_starts <- function(text) {
  if (is.na(text) || !nzchar(text)) {
    return(1L)
  }
  nl <- gregexpr("\n", text, fixed = TRUE)[[1]]
  if (length(nl) == 1L && nl[1] == -1L) {
    return(1L)
  }
  c(1L, nl + 1L)
}

pos_to_line_col <- function(text, pos) {
  starts <- line_starts(text)
  line <- findInterval(pos, starts)
  line <- max(1L, line)
  col <- pos - starts[line] + 1L
  list(line = line, col = col)
}

trim_ws <- function(x) gsub("^\\s+|\\s+$", "", x)
collapse_ws <- function(x) gsub("\\s+", " ", x)

extract_context <- function(text, pos, len = 180L) {
  end <- min(nchar(text), pos + len - 1L)
  start <- max(1L, pos - 40L)
  x <- substr(text, start, end)
  x <- gsub("[\r\n\t]+", " ", x)
  x <- collapse_ws(x)
  trim_ws(x)
}

make_match_row <- function(file, text, pos, match_text, rule, heuristic = FALSE) {
  lc <- pos_to_line_col(text, pos)
  data.frame(
    file = norm_path(file),
    line = lc$line,
    col = lc$col,
    id = rule$id,
    package = rule$package,
    stage = rule$stage,
    confidence = rule$confidence,
    heuristic = heuristic,
    match = substr(match_text, 1, 400),
    context = extract_context(text, pos, len = 180L),
    suggestion = rule$suggestion,
    stringsAsFactors = FALSE
  )
}

ensure_dir_for_file <- function(path) {
  d <- dirname(path)
  if (!dir.exists(d)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

list_source_files <- function(root = ".",
                              include_ext = c("r", "R", "Rmd", "rmd", "qmd", "Qmd", "Rnw", "rnw"),
                              include_special = c(".Rprofile"),
                              exclude_dirs = c(
                                ".git", ".Rproj.user", "renv", "packrat", "_targets",
                                "node_modules", ".quarto", ".venv", "venv", "env",
                                "__pycache__", ".mypy_cache"
                              )) {
  all_paths <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
  all_paths <- all_paths[file.info(all_paths)$isdir %in% FALSE]
  all_paths <- norm_path(all_paths)

  if (length(exclude_dirs)) {
    ex_pat <- paste0("(^|/)(", paste(escape_regex_literal(exclude_dirs), collapse = "|"), ")(/|$)")
    all_paths <- all_paths[!grepl(ex_pat, all_paths, perl = TRUE)]
  }

  ext <- tools::file_ext(all_paths)
  is_ext <- ext %in% include_ext
  is_special <- basename(all_paths) %in% include_special

  all_paths[is_ext | is_special]
}

# ============================================================
# Rule catalogue (row-by-row; avoids length mismatch bugs)
# ============================================================

build_rule_catalogue <- function() {
  rows <- list()

  add_rule <- function(id, package, stage, confidence, regex, suggestion) {
    rows[[length(rows) + 1L]] <<- data.frame(
      id = id,
      package = package,
      stage = stage,
      confidence = confidence,
      regex = regex,
      suggestion = suggestion,
      stringsAsFactors = FALSE
    )
  }

  # -----------------------------
  # dplyr
  # -----------------------------
  add_rule(
    "dplyr_colwise_scoped_verbs", "dplyr", "superseded/deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:mutate|summari[sz]e|filter|select|rename)_(?:at|if|all)\\s*\\(",
    "Replace scoped verbs (`*_at/_if/_all`) with `across()` / `if_any()` / `if_all()` depending on intent."
  )
  add_rule(
    "dplyr_underscore_verbs", "dplyr", "deprecated/defunct in modern dplyr", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:add_count_|add_tally_|arrange_|count_|distinct_|do_|filter_|funs_|group_by_|group_indices_|mutate_|tally_|transmute_|rename_|select_|slice_|summari[sz]e_)\\s*\\(",
    "Replace underscore NSE verbs with modern tidy-eval (non-underscore verbs + tidy evaluation)."
  )
  add_rule(
    "dplyr_cur_data", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?cur_data(?:_all)?\\s*\\(",
    "Replace `cur_data()` / `cur_data_all()` with `pick()` where appropriate."
  )
  add_rule(
    "dplyr_funs", "dplyr", "superseded/deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?funs\\s*\\(",
    "Replace `funs()` with anonymous functions or `list(...)` inside `across()`."
  )
  add_rule(
    "dplyr_all_equal", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?all_equal\\s*\\(",
    "Replace `all_equal()` with base `all.equal()` (check semantics)."
  )
  add_rule(
    "dplyr_progress_estimated", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?progress_estimated\\s*\\(",
    "Avoid `progress_estimated()`; use alternatives such as cli/progress."
  )
  add_rule(
    "dplyr_join_multiple_null", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:left_join|right_join|inner_join|full_join|semi_join|anti_join|nest_join)\\s*\\([\\s\\S]{0,500}?\\bmultiple\\s*=\\s*NULL\\b",
    "Use `multiple = \"all\"` (or explicit join strategy) instead of `multiple = NULL`."
  )
  add_rule(
    "dplyr_join_multiple_warning_error", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:left_join|right_join|inner_join|full_join|semi_join|anti_join|nest_join)\\s*\\([\\s\\S]{0,500}?\\bmultiple\\s*=\\s*\"(?:warning|error)\"",
    "Use `relationship = \"many-to-one\"` (or suitable relationship) instead of `multiple = \"warning\"/\"error\"`."
  )
  add_rule(
    "dplyr_cross_join_by_character", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:left_join|right_join|inner_join|full_join)\\s*\\([\\s\\S]{0,500}?\\bby\\s*=\\s*character\\s*\\(\\s*\\)",
    "Use `cross_join()` instead of `by = character()` for cross joins."
  )
  add_rule(
    "dplyr_group_by_add_arg", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?group_by\\s*\\([\\s\\S]{0,500}?\\badd\\s*=",
    "Use `.add =` instead of `add =` in `group_by()`."
  )
  add_rule(
    "dplyr_group_map_keep_arg", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?group_(?:map|modify|split)\\s*\\([\\s\\S]{0,500}?\\bkeep\\s*=",
    "Use `.keep =` instead of `keep =` in `group_map()` / `group_modify()` / `group_split()`."
  )
  add_rule(
    "dplyr_filter_across", "dplyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?filter\\s*\\([\\s\\S]{0,400}?\\bacross\\s*\\(",
    "In `filter()`, replace `across()` conditions with `if_any()` / `if_all()`."
  )
  add_rule(
    "dplyr_across_missing_cols_heuristic", "dplyr", "deprecated (heuristic)", "medium",
    "\\b(?:[[:alnum:]_.]+::)?across\\s*\\(\\s*(?:~|function\\s*\\()",
    "Heuristic: `across()` may be missing `.cols` (deprecated). Review and make `.cols` explicit."
  )
  add_rule(
    "dplyr_across_extra_positional_args_heuristic", "dplyr", "deprecated (heuristic)", "medium",
    "\\b(?:[[:alnum:]_.]+::)?across\\s*\\(\\s*[^,\\)]+\\s*,\\s*[^,\\)]+\\s*,\\s*(?!\\s*\\.(?:names|unpack)\\s*=)",
    "Heuristic: extra positional args in `across()` may rely on deprecated `...`; prefer anonymous function."
  )
  add_rule(
    "dplyr_top_n", "dplyr", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:top_n|top_frac)\\s*\\(",
    "Replace `top_n()`/`top_frac()` with `slice_max()` or `slice_min()`."
  )
  add_rule(
    "dplyr_sample_n", "dplyr", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:sample_n|sample_frac)\\s*\\(",
    "Replace `sample_n()`/`sample_frac()` with `slice_sample()`."
  )
  add_rule(
    "dplyr_combine", "dplyr", "deprecated/defunct", "high",
    "\\b(?:[[:alnum:]_.]+::)?combine\\s*\\(",
    "Replace `dplyr::combine()` with `vctrs::vec_c()` or `c()`."
  )

  # -----------------------------
  # tidyr
  # -----------------------------
  add_rule(
    "tidyr_gather", "tidyr", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?gather\\s*\\(",
    "Prefer `pivot_longer()` for new code."
  )
  add_rule(
    "tidyr_spread", "tidyr", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?spread\\s*\\(",
    "Prefer `pivot_wider()` for new code."
  )
  add_rule(
    "tidyr_underscore_variants", "tidyr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:gather_|spread_|nest_|unnest_|separate_|unite_|extract_|complete_|drop_na_|replace_na_|fill_|expand_|crossing_)\\s*\\(",
    "Old tidyr underscore/lazyeval variants are deprecated; migrate to modern tidyr + tidy-eval."
  )
  add_rule(
    "tidyr_separate", "tidyr", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?separate\\s*\\(",
    "Superseded: replace `separate()` with `separate_wider_delim()`, `separate_wider_regex()`, or `separate_wider_position()`."
  )
  add_rule(
    "tidyr_extract", "tidyr", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?extract\\s*\\(",
    "Superseded: replace `extract()` with `separate_wider_regex()`."
  )
  add_rule(
    "tidyr_nest_unnest_heuristic", "tidyr", "review (API changes over time)", "medium",
    "\\b(?:[[:alnum:]_.]+::)?(?:nest|unnest)\\s*\\(",
    "Heuristic review: check modern signatures (`nest(data = c(...))`, `unnest(cols = ...)`) and current tidyr usage."
  )

  # -----------------------------
  # tibble
  # -----------------------------
  add_rule(
    "tibble_as_data_frame", "tibble", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?as_data_frame\\s*\\(",
    "Use `tibble::as_tibble()` instead of `as_data_frame()`."
  )
  add_rule(
    "tibble_data_frame", "tibble", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?data_frame\\s*\\(",
    "Use `tibble::tibble()` (or `as_tibble()`) instead of `data_frame()`."
  )
  add_rule(
    "tibble_tbl_df", "tibble", "deprecated/legacy", "high",
    "\\b(?:[[:alnum:]_.]+::)?tbl_df\\s*\\(",
    "Avoid `tbl_df()`; use tibbles (`tibble::as_tibble()` / `tibble::tibble()`)."
  )

  # -----------------------------
  # tidyselect (ONLY safe regex rules here)
  # NOTE: .data and bare predicates are handled by bounded scanners below
  # to avoid cross-pipeline false positives.
  # -----------------------------
  add_rule(
    "tidyselect_setops_style_recommendation", "tidyselect", "style recommendation", "medium",
    "\\b(?:starts_with|ends_with|contains|matches|where|last_col)\\s*\\([^\\)]*\\)\\s*-\\s*(?:starts_with|ends_with|contains|matches|where|last_col)\\s*\\(",
    "Set-op style (`x - y`) is still supported, but Boolean style (`x & !y`) is now recommended for readability."
  )

  # -----------------------------
  # purrr
  # -----------------------------
  add_rule(
    "purrr_map_df", "purrr", "superseded", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:i?map|map2|pmap)_(?:dfr|dfc)\\s*\\(",
    "Replace `*_dfr()`/`*_dfc()` with `map()` + `list_rbind()` / `list_cbind()`."
  )
  add_rule(
    "purrr_cross", "purrr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:cross|cross2|cross3|cross_df)\\s*\\(",
    "Replace `cross*()` with `tidyr::expand_grid()`."
  )
  add_rule(
    "purrr_invoke", "purrr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:invoke|invoke_map)\\s*\\(",
    "Replace `invoke()` / `invoke_map()` with `rlang::exec()` (often with `map()`/`map2()`)."
  )
  add_rule(
    "purrr_lift", "purrr", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?lift(?:_dl|_vd|_dv|_vl|_ld|_lv)?\\s*\\(",
    "Deprecated purrr `lift*()` family: replace with explicit wrappers / `rlang::exec()` / `rlang::inject()` patterns."
  )

  # -----------------------------
  # ggplot2
  # -----------------------------
  add_rule(
    "ggplot2_aes_string", "ggplot2", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?(?:aes_string|aes_|aes_q)\\s*\\(",
    "Replace `aes_string()` / `aes_()` / `aes_q()` with `aes()` + tidy evaluation."
  )
  add_rule(
    "ggplot2_qplot", "ggplot2", "deprecated", "high",
    "\\b(?:[[:alnum:]_.]+::)?qplot\\s*\\(",
    "Replace `qplot()` with `ggplot()` + geoms."
  )
  add_rule(
    "ggplot2_linewidth", "ggplot2", "deprecated (heuristic)", "high",
    "\\b(?:[[:alnum:]_.]+::)?geom_(?:line|hline|vline|abline|path|step|segment|curve|smooth|density)\\s*\\([\\s\\S]{0,400}?\\bsize\\s*=",
    "For line geoms, use `linewidth =` instead of `size =` (review exceptions in mixed geoms)."
  )

  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

# ============================================================
# Generic regex scanning
# ============================================================

scan_text_with_rule <- function(text, file, rule) {
  m <- gregexpr(rule$regex, text, perl = TRUE, ignore.case = FALSE)[[1]]
  if (length(m) == 1L && m[1] == -1L) {
    return(NULL)
  }

  lens <- attr(m, "match.length")
  out <- vector("list", length(m))

  for (i in seq_along(m)) {
    pos <- m[i]
    len <- lens[i]
    out[[i]] <- make_match_row(
      file = file,
      text = text,
      pos = pos,
      match_text = substr(text, pos, pos + len - 1L),
      rule = rule,
      heuristic = grepl("heuristic|review", rule$stage, ignore.case = TRUE)
    )
  }

  do.call(rbind, out)
}

# ============================================================
# Heuristic / bounded scanners (tidyselect)
# ============================================================

# Real deprecation target: external vectors in tidyselect contexts without all_of()/any_of()
# Example deprecated pattern:
#   cols <- c("a", "b")
#   df %>% select(cols)
#   df %>% select(-cols)
# Preferred:
#   select(all_of(cols)) / select(-any_of(cols))
scan_tidyselect_external_vector_indirection <- function(text, file) {
  assign_pat <- paste0(
    "(?m)^\\s*([A-Za-z.][A-Za-z0-9._]*)\\s*(?:<-|=)\\s*",
    "(?:",
    "\"[^\"]+\"|'[^']+'",
    "|c\\s*\\((?:\\s*(?:\"[^\"]+\"|'[^']+')\\s*,?)+\\s*\\)",
    ")"
  )

  am <- gregexpr(assign_pat, text, perl = TRUE)[[1]]
  if (length(am) == 1L && am[1] == -1L) {
    return(NULL)
  }

  al <- attr(am, "match.length")
  syms <- character(0)

  for (i in seq_along(am)) {
    s <- substr(text, am[i], am[i] + al[i] - 1L)
    nm <- sub("(?m)^\\s*([A-Za-z.][A-Za-z0-9._]*)\\s*(?:<-|=).*", "\\1", s, perl = TRUE)
    syms <- c(syms, nm)
  }
  syms <- unique(syms)
  if (!length(syms)) {
    return(NULL)
  }

  call_pat <- "\\b(?:dplyr::|tidyr::)?(?:select|rename|relocate|pick|c_across|across|if_any|if_all)\\s*\\([\\s\\S]{0,500}?\\)"
  cm <- gregexpr(call_pat, text, perl = TRUE)[[1]]
  if (length(cm) == 1L && cm[1] == -1L) {
    return(NULL)
  }
  cl <- attr(cm, "match.length")

  rule <- data.frame(
    id = "tidyselect_external_vector_indirection_heuristic",
    package = "tidyselect",
    stage = "deprecated (heuristic)",
    confidence = "medium",
    regex = NA_character_,
    suggestion = "Likely deprecated tidyselect indirection (external vector) in selection context. Wrap character vectors with `all_of()` or `any_of()`.",
    stringsAsFactors = FALSE
  )

  out <- list()

  for (j in seq_along(cm)) {
    cpos <- cm[j]
    ctxt <- substr(text, cpos, cpos + cl[j] - 1L)
    ctxt_trim <- trimws(ctxt)

    # Skip calls already using all_of/any_of
    if (grepl("\\b(?:all_of|any_of)\\s*\\(", ctxt, perl = TRUE)) next

    # Skip common literal-name selects like select("a", "b", "c") / dplyr::select(...)
    if (grepl("^\\s*(?:dplyr::)?select\\s*\\(\\s*(?:\"[^\"]+\"|'[^']+')\\s*(?:,\\s*(?:\"[^\"]+\"|'[^']+'))*\\s*\\)\\s*$",
      ctxt_trim,
      perl = TRUE
    )) {
      next
    }

    for (nm in syms) {
      # Do not match names inside quotes/backticks, e.g. "year", 'year', `year`
      tok_pat <- paste0("(?<!['\"`])\\b", escape_regex_literal(nm), "\\b(?!['\"`])")

      tm <- gregexpr(tok_pat, ctxt, perl = TRUE)[[1]]
      if (length(tm) == 1L && tm[1] == -1L) next

      # Skip obvious function definitions inside captured text
      if (grepl(paste0("\\bfunction\\s*\\([^\\)]*\\b", escape_regex_literal(nm), "\\b"), ctxt, perl = TRUE)) next

      local_pos <- tm[1]
      abs_pos <- cpos + local_pos - 1L
      mtxt <- substr(ctxt, local_pos, local_pos + attr(tm, "match.length")[1] - 1L)

      out[[length(out) + 1L]] <- make_match_row(
        file = file, text = text, pos = abs_pos, match_text = mtxt, rule = rule, heuristic = TRUE
      )
    }
  }

  if (!length(out)) {
    return(NULL)
  }

  res <- do.call(rbind, out)
  key <- paste(res$file, res$line, res$col, res$id, res$match, sep = "||")
  res <- res[!duplicated(key), , drop = FALSE]
  rownames(res) <- NULL
  res
}

# Bare predicates in tidyselect contexts (e.g. select(is.numeric)) -> where(is.numeric)
scan_tidyselect_bare_predicates <- function(text, file) {
  rule <- data.frame(
    id = "tidyselect_bare_predicates_scanner",
    package = "tidyselect",
    stage = "deprecated (heuristic)",
    confidence = "medium",
    regex = NA_character_,
    suggestion = "Bare predicates in tidy-select are deprecated; use `where(is.<predicate>)`.",
    stringsAsFactors = FALSE
  )

  call_pat <- "\\b(?:dplyr::|tidyr::)?(?:select|rename|relocate|pick|c_across|across)\\s*\\([\\s\\S]{0,500}?\\)"
  cm <- gregexpr(call_pat, text, perl = TRUE)[[1]]
  if (length(cm) == 1L && cm[1] == -1L) {
    return(NULL)
  }
  cl <- attr(cm, "match.length")

  out <- list()

  for (j in seq_along(cm)) {
    cpos <- cm[j]
    ctxt <- substr(text, cpos, cpos + cl[j] - 1L)
    ctxt_trim <- trimws(ctxt)

    # Skip simple string-only select(...) calls (common and valid)
    if (grepl("^\\s*(?:dplyr::)?select\\s*\\(\\s*(?:\"[^\"]+\"|'[^']+')\\s*(?:,\\s*(?:\"[^\"]+\"|'[^']+'))*\\s*\\)\\s*$",
      ctxt_trim,
      perl = TRUE
    )) {
      next
    }

    pm <- gregexpr("\\bis\\.[A-Za-z][A-Za-z0-9._]*\\b", ctxt, perl = TRUE)[[1]]
    if (length(pm) == 1L && pm[1] == -1L) next
    pl <- attr(pm, "match.length")

    for (k in seq_along(pm)) {
      ppos <- pm[k]
      pred <- substr(ctxt, ppos, ppos + pl[k] - 1L)

      # Skip where(is.xxx)
      left_window_start <- max(1L, ppos - 50L)
      left_text <- substr(ctxt, left_window_start, ppos - 1L)
      if (grepl("where\\s*\\(\\s*$", left_text, perl = TRUE)) next
      if (grepl(paste0("where\\s*\\(\\s*", escape_regex_literal(pred), "\\s*\\)"), ctxt, perl = TRUE)) next

      # Skip common non-selector predicate usage in formulas/lambdas
      if (grepl(paste0("~\\s*", escape_regex_literal(pred), "\\s*\\("), ctxt, perl = TRUE)) next
      if (grepl(paste0("function\\s*\\([^\\)]*\\)\\s*", escape_regex_literal(pred), "\\s*\\("), ctxt, perl = TRUE)) next

      abs_pos <- cpos + ppos - 1L
      out[[length(out) + 1L]] <- make_match_row(
        file = file, text = text, pos = abs_pos, match_text = pred, rule = rule, heuristic = TRUE
      )
    }
  }

  if (!length(out)) {
    return(NULL)
  }

  res <- do.call(rbind, out)
  key <- paste(res$file, res$line, res$col, res$id, res$match, sep = "||")
  res <- res[!duplicated(key), , drop = FALSE]
  rownames(res) <- NULL
  res
}

# .data in tidyselect expressions (bounded scanner to avoid cross-pipeline false positives)
scan_tidyselect_dotdata_in_selection <- function(text, file) {
  rule <- data.frame(
    id = "tidyselect_dotdata_in_selection_scanner",
    package = "tidyselect",
    stage = "deprecated",
    confidence = "high",
    regex = NA_character_,
    suggestion = "In tidy-select contexts, replace `.data$x` with \"x\" and `.data[[var]]` with `all_of(var)` / `any_of(var)`.",
    stringsAsFactors = FALSE
  )

  call_pat <- "\\b(?:dplyr::|tidyr::)?(?:select|rename|relocate|pick|c_across|across)\\s*\\([\\s\\S]{0,500}?\\)"
  cm <- gregexpr(call_pat, text, perl = TRUE)[[1]]
  if (length(cm) == 1L && cm[1] == -1L) {
    return(NULL)
  }
  cl <- attr(cm, "match.length")

  out <- list()

  for (j in seq_along(cm)) {
    cpos <- cm[j]
    ctxt <- substr(text, cpos, cpos + cl[j] - 1L)
    ctxt_trim <- trimws(ctxt)

    # Skip simple string-only select(...) calls (common and valid)
    if (grepl("^\\s*(?:dplyr::)?select\\s*\\(\\s*(?:\"[^\"]+\"|'[^']+')\\s*(?:,\\s*(?:\"[^\"]+\"|'[^']+'))*\\s*\\)\\s*$",
      ctxt_trim,
      perl = TRUE
    )) {
      next
    }

    dm <- gregexpr("\\.data\\s*(?:\\$|\\[\\[)", ctxt, perl = TRUE)[[1]]
    if (length(dm) == 1L && dm[1] == -1L) next
    dl <- attr(dm, "match.length")

    for (k in seq_along(dm)) {
      local_pos <- dm[k]
      abs_pos <- cpos + local_pos - 1L
      mtxt <- substr(ctxt, local_pos, local_pos + dl[k] - 1L)

      out[[length(out) + 1L]] <- make_match_row(
        file = file, text = text, pos = abs_pos, match_text = mtxt, rule = rule, heuristic = FALSE
      )
    }
  }

  if (!length(out)) {
    return(NULL)
  }

  res <- do.call(rbind, out)
  key <- paste(res$file, res$line, res$col, res$id, res$match, sep = "||")
  res <- res[!duplicated(key), , drop = FALSE]
  rownames(res) <- NULL
  res
}

# ============================================================
# Main audit
# ============================================================

audit_tidyverse_deprecations <- function(root = ".",
                                         output_csv = NULL,
                                         summary_csv = NULL,
                                         files = NULL,
                                         verbose = TRUE) {
  rules <- build_rule_catalogue()

  if (is.null(files)) {
    files <- list_source_files(root = root)
  } else {
    files <- norm_path(files)
    files <- files[file.exists(files)]
  }

  if (!length(files)) {
    warning("No source files found to scan.")
    empty_matches <- data.frame(
      file = character(0), line = integer(0), col = integer(0),
      id = character(0), package = character(0), stage = character(0),
      confidence = character(0), heuristic = logical(0),
      match = character(0), context = character(0), suggestion = character(0),
      stringsAsFactors = FALSE
    )
    empty_summary <- data.frame(
      package = character(0), id = character(0), stage = character(0),
      confidence = character(0), n = integer(0), files = integer(0),
      stringsAsFactors = FALSE
    )
    return(list(matches = empty_matches, summary = empty_summary, rules = rules, files = files))
  }

  all_matches <- list()

  for (f in files) {
    txt <- safe_read_text(f)
    if (!nzchar(txt)) next

    # Generic regex rules
    for (r in seq_len(nrow(rules))) {
      hit <- scan_text_with_rule(txt, f, rules[r, , drop = FALSE])
      if (!is.null(hit) && nrow(hit)) {
        all_matches[[length(all_matches) + 1L]] <- hit
      }
    }

    # Bounded scanners (tidyselect)
    h1 <- scan_tidyselect_external_vector_indirection(txt, f)
    if (!is.null(h1) && nrow(h1)) all_matches[[length(all_matches) + 1L]] <- h1

    h2 <- scan_tidyselect_bare_predicates(txt, f)
    if (!is.null(h2) && nrow(h2)) all_matches[[length(all_matches) + 1L]] <- h2

    h3 <- scan_tidyselect_dotdata_in_selection(txt, f)
    if (!is.null(h3) && nrow(h3)) all_matches[[length(all_matches) + 1L]] <- h3
  }

  if (!length(all_matches)) {
    matches <- data.frame(
      file = character(0), line = integer(0), col = integer(0),
      id = character(0), package = character(0), stage = character(0),
      confidence = character(0), heuristic = logical(0),
      match = character(0), context = character(0), suggestion = character(0),
      stringsAsFactors = FALSE
    )
  } else {
    matches <- do.call(rbind, all_matches)

    key <- paste(matches$file, matches$line, matches$col, matches$id, sep = "||")
    matches <- matches[!duplicated(key), , drop = FALSE]

    ord <- order(matches$file, matches$line, matches$col, matches$package, matches$id)
    matches <- matches[ord, , drop = FALSE]
    rownames(matches) <- NULL
  }

  # Summary
  if (!nrow(matches)) {
    summary_df <- data.frame(
      package = character(0), id = character(0), stage = character(0),
      confidence = character(0), n = integer(0), files = integer(0),
      stringsAsFactors = FALSE
    )
  } else {
    split_key <- paste(matches$package, matches$id, matches$stage, matches$confidence, sep = "\r")
    idx <- split(seq_len(nrow(matches)), split_key)

    summary_df <- do.call(rbind, lapply(idx, function(ii) {
      data.frame(
        package = matches$package[ii[1]],
        id = matches$id[ii[1]],
        stage = matches$stage[ii[1]],
        confidence = matches$confidence[ii[1]],
        n = length(ii),
        files = length(unique(matches$file[ii])),
        stringsAsFactors = FALSE
      )
    }))

    summary_df <- summary_df[order(summary_df$package, -summary_df$n, summary_df$id), , drop = FALSE]
    rownames(summary_df) <- NULL
  }

  # Write outputs
  if (!is.null(output_csv)) {
    ensure_dir_for_file(output_csv)
    utils::write.csv(matches, output_csv, row.names = FALSE, na = "")
  }

  if (is.null(summary_csv) && !is.null(output_csv)) {
    base <- sub("\\.csv$", "", output_csv, ignore.case = TRUE)
    summary_csv <- paste0(base, "_summary.csv")
  }

  if (!is.null(summary_csv)) {
    ensure_dir_for_file(summary_csv)
    utils::write.csv(summary_df, summary_csv, row.names = FALSE, na = "")
  }

  if (isTRUE(verbose)) {
    cat("\nTidyverse lifecycle audit (static scan)\n")
    cat("Root: ", normalizePath(root, winslash = "/", mustWork = FALSE), "\n", sep = "")
    cat("Files scanned: ", length(files), "\n", sep = "")
    cat("Findings: ", nrow(matches), "\n", sep = "")

    if (nrow(summary_df)) {
      cat("\nTop findings:\n")
      print(utils::head(summary_df, 20), row.names = FALSE)
    } else {
      cat("No matches found.\n")
    }

    if (!is.null(output_csv)) cat("\nDetailed CSV: ", norm_path(output_csv), "\n", sep = "")
    if (!is.null(summary_csv)) cat("Summary CSV:  ", norm_path(summary_csv), "\n", sep = "")
  }

  list(
    matches = matches,
    summary = summary_df,
    rules = rules,
    files = files
  )
}

# ============================================================
# Optional helper
# ============================================================

subset_high_confidence <- function(res) {
  if (is.null(res$matches) || !nrow(res$matches)) {
    return(res$matches)
  }
  res$matches[res$matches$confidence == "high", , drop = FALSE]
}
