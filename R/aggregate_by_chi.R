#' Aggregate by CHI
#'
#' @description Aggregate episode file by CHI to convert into
#' individual file.
#'
#' @importFrom data.table .N
#' @importFrom data.table .SD
#' @param year financial year, string, eg "1920"
#' @param exclude_sc_var Boolean, whether exclude social care variables
#'
#' @inheritParams create_individual_file
aggregate_by_chi <- function(episode_file, year, exclude_sc_var = FALSE) {
  # recommended by `data.table` team to tackle the issue
  # "no visible binding for global variable"
  gender <-
    chi <-
    cij_ppa <-
    cij_end_date <- cij_start_date <- preventable_beddays <- NULL


  # Convert to data.table
  data.table::setDT(episode_file)

  # Ensure all variable names are lowercase
  data.table::setnames(episode_file, stringr::str_to_lower)

  # Sort the data
  data.table::setkeyv(
    episode_file,
    c(
      "chi",
      "record_keydate1",
      "keytime1",
      "record_keydate2",
      "keytime2"
    )
  )

  if (exclude_sc_var) {
    data.table::setnames(
      episode_file,
      c(
        "cij_marker",
        "ooh_case_id"
      ),
      c(
        "cij_total",
        "ooh_cases"
      )
    )
  } else {
    data.table::setnames(
      episode_file,
      c(
        "ch_chi_cis",
        "cij_marker",
        "ooh_case_id"
      ),
      c(
        "ch_cis_episodes",
        "cij_total",
        "ooh_cases"
      )
    )
  }

  # column specification, grouped by chi
  # columns to select last
  cols2 <- c(
    "postcode",
    "dob",
    "gpprac",
    vars_start_with(episode_file, "sc_")
  )
  if (exclude_sc_var) {
    cols2 <- cols2[!(cols2 %in% vars_start_with(episode_file, "sc_"))]
  }
  # columns to count unique rows
  cols3 <- c(
    "ch_cis_episodes",
    "cij_total",
    "cij_el",
    "cij_non_el",
    "cij_mat",
    "cij_delay",
    "ooh_cases",
    "preventable_admissions"
  )
  if (exclude_sc_var) {
    cols3 <- cols3[!(cols3 %in% "ch_cis_episodes")]
  }
  # columns to sum up
  cols4 <- c(
    vars_end_with(
      episode_file,
      c(
        "episodes",
        "beddays",
        "cost",
        "_dnas",
        "attendances",
        "attend",
        "contacts",
        "hours",
        "alarms",
        "telecare",
        "paid_items",
        "advice",
        "homev",
        "time",
        "assessment",
        "other",
        "dn",
        "nhs24",
        "pcc"
      )
    ),
    vars_start_with(
      episode_file,
      "sds_option"
    )
  )
  cols4 <- cols4[!(cols4 %in% "ch_cis_episodes")]
  if (exclude_sc_var) {
    cols4 <-
      cols4[!(cols4 %in% c(
        vars_end_with(
          episode_file,
          c(
            "alarms",
            "telecare"
          )
        ),
        vars_start_with(
          episode_file,
          "sds_option"
        )
      ))]
  }
  # columns to select maximum
  cols5 <- c("nsu", vars_contain(episode_file, "hl1_in_fy"))
  data.table::setnafill(episode_file, fill = 0L, cols = cols5)
  # compute
  individual_file_cols1 <- episode_file[,
    list(gender = mean(gender)),
    by = "anon_chi"
  ]
  individual_file_cols2 <- episode_file[,
    .SD[.N],
    .SDcols = cols2,
    by = "anon_chi"
  ]
  individual_file_cols3 <- episode_file[,
    lapply(.SD, function(x) {
      data.table::uniqueN(x, na.rm = TRUE)
    }),
    .SDcols = cols3,
    by = "anon_chi"
  ]
  individual_file_cols4 <- episode_file[,
    lapply(.SD, function(x) {
      sum(x, na.rm = TRUE)
    }),
    .SDcols = cols4,
    by = "anon_chi"
  ]
  individual_file_cols5 <- episode_file[,
    lapply(.SD, function(x) max(x, na.rm = TRUE)),
    .SDcols = cols5,
    by = "anon_chi"
  ]
  individual_file_cols6 <- episode_file[,
    list(
      preventable_beddays = ifelse(
        any(cij_ppa, na.rm = TRUE),
        as.integer(min(cij_end_date, end_fy(year)) - max(cij_start_date, start_fy(year))),
        NA_integer_
      )
    ),
    # cij_marker has been renamed as cij_total
    by = c("anon_chi", "cij_total")
  ]
  individual_file_cols6 <- individual_file_cols6[,
    list(
      preventable_beddays = sum(preventable_beddays, na.rm = TRUE)
    ),
    by = "anon_chi"
  ]

  individual_file <- dplyr::bind_cols(
    individual_file_cols1,
    individual_file_cols2[, chi := NULL],
    individual_file_cols3[, chi := NULL],
    individual_file_cols4[, chi := NULL],
    individual_file_cols5[, chi := NULL],
    individual_file_cols6[, chi := NULL]
  )
  individual_file <- individual_file[, year := year]

  cli::cli_alert_info("Aggregate by CHI function finished at {Sys.time()}")

  # convert back to tibble
  return(dplyr::as_tibble(individual_file))
}


#' Select columns according to a pattern
#'
#' @describeIn vars_select Choose variables ending in a given pattern.
#'
#' @param data The data from which to select columns/variables.
#' @param vars The variables / pattern to find, as a character vector
#' @param ignore_case Should case be ignored (Default: FALSE)
vars_end_with <- function(data, vars, ignore_case = FALSE) {
  names(data)[stringr::str_ends(
    names(data),
    stringr::regex(paste(vars, collapse = "|"),
      ignore_case = ignore_case
    )
  )]
}

#' @describeIn vars_select Choose variables starting with a given pattern.
vars_start_with <- function(data, vars, ignore_case = FALSE) {
  names(data)[stringr::str_starts(
    names(data),
    stringr::regex(paste(vars, collapse = "|"),
      ignore_case = ignore_case
    )
  )]
}

#' @describeIn vars_select Choose variables which contain a given pattern.
vars_contain <- function(data, vars, ignore_case = FALSE) {
  stringr::str_subset(
    names(data),
    stringr::regex(paste(vars, collapse = "|"),
      ignore_case = ignore_case
    )
  )
}

#' Aggregate Care Home episodes to ch_cis
#'
#' @description Aggregate CH variables by CHI and CIS.
#'
#' @inheritParams create_individual_file
aggregate_ch_episodes <- function(episode_file) {
  # recommended by `data.table` team to tackle the issue
  # "no visible binding for global variable"
  ch_no_cost <-
    record_keydate1 <- ch_ep_end <- ch_cost_per_day <- anon_chi <- NULL

  # Convert to data.table
  data.table::setDT(episode_file)

  # Perform grouping and aggregation
  episode_file[, c(
    "ch_no_cost",
    "ch_ep_start",
    "ch_ep_end",
    "ch_cost_per_day"
  ) := list(
    max(ch_no_cost),
    min(record_keydate1),
    max(ch_ep_end),
    mean(ch_cost_per_day)
  ),
  by = c("anon_chi", "ch_chi_cis")
  ]

  # Convert back to tibble if needed
  episode_file <- tibble::as_tibble(episode_file)

  cli::cli_alert_info("Aggregate ch episodes function finished at {Sys.time()}")

  return(episode_file)
}
