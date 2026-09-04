# notes:
# Need to manually save a local copy of
# Source Final Interface spec v0.1.xlsx frequently
# to

library(openxlsx)
library(dplyr)
library(createslf)
rm(list = ls())

# Initialising ----

## PHS copy of Fianl Interface Spec ----
phs_spec_copy_path <- file.path(
  "/conf/sourcedev/Source_Linkage_File_Updates/byoc_datatype",
  "PHS_Source Final Interface Specification v0.1.xlsx"
)

## Define mapping -----
mapping <- tibble::tribble(
  ~dataset_id, ~spec_sheetname,
  "ae", "sdl_ae_processed",
  "chi_deaths", "sdl_chi_deaths_processed ",
  "combined_deaths", "sdl_refined_deaths_processed",
  "dd", "sdl_delayed_discharge_processed",
  "gp_ooh", "sdl_gp_ooh_processed ",
  "homelessness", "sdl_homelessness_processed ",
  "homelessness_completeness", "sdl_homessless_completeness_pro",
  "ltc", "sdl_long_term_condition_process",
  "maternity", "sdl_maternity_processed ",
  "mh", "sdl_mental_health_processed ",
  "nrs_deaths", "sdl_nrs_deaths_processed ",
  "ooh_cost_lookup", "sdl_gp_ooh_cost_lookup_proces",
  "outpatients", "sdl_outpatients_processed "
)


## List datasets to check ----
# listed in run_sdl.r

datasets <- c(
  "ae",
  "chi_deaths",
  "combined_deaths",
  "dd",
  "gp_ooh",
  "homelessness",
  "homelessness_completeness",
  "ltc",
  "maternity",
  "mh",
  "nrs_deaths",
  "ooh_cost_lookup",
  "outpatients"
)

wb <- createWorkbook()

## colour definition in the excel ----
red_style <- createStyle(
  fgFill = "#F8696B"
)
green_style <- createStyle(
  bgFill = "#C6EFCE" # light green
)
red_light_style <- createStyle(
  bgFill = "#FFC7CE" # light red
)

year <- "1920"

file_list_byoc <- get_byoc_output_files(year = "1920", types = datasets)
file_list <- data.frame(
  dataset_id = names(file_list_byoc),
  file_name = unlist(file_list_byoc),
  row.names = NULL
)
rm(file_list_byoc)
mapping <- mapping %>%
  left_join(file_list, by = "dataset_id")

dataset_summary <- data.frame(
  dataset = character(),
  file_name = character(),
  rows = numeric(),
  columns = numeric(),
  stringsAsFactors = FALSE
)


## normlise data type ----
normalise_type <- function(x) {
  x <- tolower(trimws(as.character(x)))

  case_when(
    grepl("hms.*difftime", x) ~ "time",
    grepl("^time", x) ~ "time",
    grepl(
      "character|text|string|varchar|varchar2|factor",
      x
    ) ~ "text",
    grepl(
      "numeric|number|decimal|double|float",
      x
    ) ~ "numeric",
    grepl(
      "integer|int",
      x
    ) ~ "integer",
    grepl(
      "date|localdate",
      x
    ) ~ "date",
    grepl(
      "datetime|timestamp|posixct|posixt",
      x
    ) ~ "datetime",
    grepl(
      "logical|boolean",
      x
    ) ~ "boolean",
    TRUE ~ x
  )
}


# Running Loop ----
for (ii in 1:length(datasets)) {
  logger::log_info(paste0("start ", ii, ", ", datasets[ii]))
  file_path <- mapping$file_name[ii]
  dataset_id <- mapping$dataset_id[ii]
  spec_sheetname <- mapping$spec_sheetname[ii]

  # Example dataframe
  df <- createslf::read_file(file_path)
  dataset_summary <- bind_rows(
    dataset_summary,
    data.frame(
      dataset = dataset_id,
      file_name = basename(file_path),
      rows = nrow(df),
      columns = ncol(df),
      stringsAsFactors = FALSE
    )
  )

  # Get variable classes
  # Get variable classes and maximum text length
  var_class <- data.frame(
    variable = names(df),
    class_data = sapply(
      df,
      function(x) paste(class(x), collapse = ", ")
    ),
    max_length = sapply(
      df,
      function(x) {
        if (is.character(x) || is.factor(x)) {
          lengths <- nchar(as.character(x))

          if (all(is.na(lengths))) {
            NA_integer_
          } else {
            max(lengths, na.rm = TRUE)
          }
        } else {
          NA_integer_
        }
      }
    ),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  spec_class <- openxlsx::read.xlsx(
    xlsxFile = phs_spec_copy_path,
    sheet = spec_sheetname,
    startRow = 12L
  ) %>%
    select(Column.Name.VDB, Data.Type) %>%
    rename(
      variable = "Column.Name.VDB",
      class_spec = "Data.Type"
    )

  # Ensure run_id and run_date_time exist
  required_vars <- c(
    "run_id",
    "run_date_time"
  )

  missing_vars <- setdiff(
    required_vars,
    var_class$variable
  )

  if (length(missing_vars) > 0) {
    var_class <- bind_rows(
      var_class,
      data.frame(
        variable = missing_vars,
        class_data = NA_character_,
        stringsAsFactors = FALSE
      )
    )
  }

  combined <- full_join(var_class, spec_class, by = "variable") %>%
    mutate(
      class_data_norm = normalise_type(class_data),
      class_spec_norm = normalise_type(class_spec),

      # Exact comparison
      match_raw = case_when(
        is.na(class_data) | is.na(class_spec) ~ NA,
        tolower(trimws(class_data)) ==
          tolower(trimws(class_spec)) ~ TRUE,
        TRUE ~ FALSE
      ),

      # Main comparison
      match = case_when(
        variable %in% c("run_id", "run_date_time") &
          class_data == "character" ~ "MATCH",
        variable %in% c("run_id", "run_date_time") &
          is.na(class_data) ~ "MISSING IN OUTPUT",
        variable %in% c("run_id", "run_date_time") ~
          "TYPE MISMATCH",
        is.na(class_data) ~
          "MISSING IN OUTPUT",
        is.na(class_spec) ~
          "NOT IN SPEC",
        class_data_norm == class_spec_norm ~
          "MATCH",
        TRUE ~
          "TYPE MISMATCH"
      )
    )

  addWorksheet(wb, sheetName = dataset_id)

  writeData(
    wb,
    sheet = dataset_id,
    x = combined
  )

  # highlight match_raw
  match_raw_col <- which(names(combined) == "match_raw")

  conditionalFormatting(
    wb,
    sheet = dataset_id,
    cols = match_raw_col,
    rows = 2:(nrow(combined) + 1),
    rule = "TRUE",
    style = green_style,
    type = "contains"
  )

  conditionalFormatting(
    wb,
    sheet = dataset_id,
    cols = match_raw_col,
    rows = 2:(nrow(combined) + 1),
    rule = "FALSE",
    style = red_light_style,
    type = "contains"
  )

  ## Highlight mismatches
  bad_rows <- which(combined$match != "MATCH") + 1

  if (length(bad_rows) > 0) {
    match_col <- which(names(combined) == "match")

    addStyle(
      wb,
      sheet = dataset_id,
      style = red_style,
      rows = bad_rows,
      cols = match_col,
      gridExpand = TRUE,
      stack = TRUE
    )
  }

  var_width <- min(
    max(nchar(combined$variable), na.rm = TRUE) + 2,
    30
  )
  # Variable column: cap width
  setColWidths(
    wb,
    sheet = dataset_id,
    cols = 1,
    widths = var_width
  )
  # Other columns: auto width
  setColWidths(
    wb,
    sheet = dataset_id,
    cols = 2:ncol(combined),
    widths = "auto"
  )

  freezePane(
    wb,
    sheet = dataset_id,
    firstRow = TRUE
  )
}

# Save output ----
addWorksheet(wb, "Dataset Summary")

writeData(
  wb,
  sheet = "Dataset Summary",
  x = dataset_summary,
  withFilter = TRUE
)

setColWidths(
  wb,
  sheet = "Dataset Summary",
  cols = 1:ncol(dataset_summary),
  widths = "auto"
)

freezePane(
  wb,
  sheet = "Dataset Summary",
  firstRow = TRUE
)

time_stamp <- format(Sys.time(), "%Y%m%d_%H%M")
saveWorkbook(
  wb,
  # Change it to whichever folder you like
  file.path(
    "/conf/sourcedev/Source_Linkage_File_Updates/byoc_datatype",
    stringr::str_glue("datatype_comparison_{time_stamp}.xlsx")
  ),
  overwrite = TRUE
)
