#' Aggregate by CHI
#'
#' @description Aggregate episode file by CHI to convert into
#' individual file.
#'
#' @importFrom data.table .N
#' @importFrom data.table .SD
#'
#' @inheritParams create_individual_file
aggregate_by_chi_zihao <- function(individual_file) {
  cli::cli_alert_info("Aggregate by CHI function started at {Sys.time()}")

  individual_file <- individual_file %>%
    dplyr::select(-c(postcode, gpprac)) %>%
    dplyr::rename(
      "gpprac" = "most_recent_gpprac",
      "postcode" = "most_recent_postcode"
    ) %>%
    dplyr::select(-c(
      dplyr::ends_with("_gpprac"),
      dplyr::ends_with("_postcode"),
      dplyr::ends_with("_DoB")
    ))

  names(individual_file) <- tolower(names(individual_file))

  data.table::setDT(individual_file) # Convert to data.table

  # Sort the data within each chunk
  data.table::setkeyv(
    individual_file,
    c(
      "chi",
      "record_keydate1",
      "keytime1",
      "record_keydate2",
      "keytime2"
    )
  )

  data.table::setnames(
    individual_file,
    c(
      "ch_chi_cis", "cij_marker", "ooh_case_id"
      # ,"hh_in_fy"
    ),
    c(
      "ch_cis_episodes", "cij_total", "ooh_cases"
      # ,"hl1_in_fy"
    )
  )

  # column specification, grouped by chi
  # columns to select last
  cols2 <- c(
    vars_end_with(
      individual_file,
      c("postcode", "dob", "ggprac")
    ),
    "ooh_cases",
    "gpprac",
    "hbrescode",
    "hscp",
    "lca",
    "ca2018",
    "locality",
    "datazone2011",
    "hbpraccode",
    "cluster",
    "simd2020v2_rank",
    "simd2020v2_sc_decile",
    "simd2020v2_sc_quintile",
    "simd2020v2_hb2019_decile",
    "simd2020v2_hb2019_quintile",
    "simd2020v2_hscp2019_decile",
    "simd2020v2_hscp2019_quintile",
    "ur8_2020",
    "ur6_2020",
    "ur3_2020",
    "ur2_2020",
    "hb2019",
    "hscp2019",
    "ca2019",
    vars_start_with(individual_file, "sc_")
  )
  # columns to count unique rows
  cols3 <- c(
    "ch_cis_episodes",
    "cij_total",
    "cij_el",
    "cij_non_el",
    "cij_mat",
    "cij_delay",
    "preventable_admissions"
  )
  # columns to sum up
  cols4 <- c(
    vars_end_with(
      individual_file,
      c(
        "episodes",
        "beddays",
        "cost",
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
        "pcc",
        "_dnas"
      )
    ),
    vars_start_with(
      individual_file,
      "sds_option"
    ),
    "health_net_costincdnas"
  )
  cols4 <- cols4[!(cols4 %in% c("ch_cis_episodes"))]
  # columns to select maximum
  cols5 <- vars_contain(individual_file, c("nsu", "hl1_in_fy"))
  cols5 <- cols5[!(cols5 %in% c("ooh_consultation_time"))]

  # compute
  individual_file_cols1 <- individual_file[,
    .(gender = mean(gender)),
    by = chi
  ]
  individual_file_cols2 <- individual_file[,
    .SD[.N],
    .SDcols = cols2,
    by = chi
  ]
  individual_file_cols3 <- individual_file[,
    lapply(.SD, function(x) {
      data.table::uniqueN(x, na.rm = TRUE)
    }),
    .SDcols = cols3,
    by = chi
  ]
  individual_file_cols4 <- individual_file[,
    lapply(.SD, function(x) {
      sum(x, na.rm = TRUE)
    }),
    .SDcols = cols4,
    by = chi
  ]
  individual_file_cols5 <- individual_file[,
    lapply(.SD, function(x) max(x, na.rm = TRUE)),
    .SDcols = cols5,
    by = chi
  ]
  individual_file_cols6 <- individual_file[,
    .(
      preventable_beddays = ifelse(
        cij_ppa == 1,
        max(cij_end_date) - min(cij_start_date),
        NA_real_
      )
    ),
    # cij_marker has been renamed as cij_total
    by = c("chi", "cij_total")
  ]
  individual_file_cols6 <- individual_file_cols6[,
    .(
      preventable_beddays =
        sum(preventable_beddays, na.rm = TRUE)
    ),
    by = "chi"
  ]

  individual_file <- dplyr::bind_cols(
    individual_file_cols1,
    individual_file_cols2[, chi := NULL],
    individual_file_cols3[, chi := NULL],
    individual_file_cols4[, chi := NULL],
    individual_file_cols5[, chi := NULL],
    individual_file_cols6[, chi := NULL]
  )
  # convert back to tibble
  individual_file <- dplyr::as_tibble(individual_file)

  return(individual_file)
}


#' select columns ending with some patterns
#' @describeIn select columns based on patterns
#'
vars_end_with <- function(data, vars, ignore_case = FALSE) {
  names(data)[stringr::str_ends(
    names(data),
    stringr::regex(paste(vars, collapse = "|"),
      ignore_case = ignore_case
    )
  )]
}

#' select columns starting with some patterns
#' @describeIn select columns based on patterns
#'
vars_start_with <- function(data, vars, ignore_case = FALSE) {
  names(data)[stringr::str_starts(
    names(data),
    stringr::regex(paste(vars, collapse = "|"),
      ignore_case = ignore_case
    )
  )]
}

#' select columns contains some characters
#' @describeIn select columns based on patterns
#'
vars_contain <- function(data, vars, ignore_case = FALSE) {
  names(data)[stringr::str_detect(
    names(data),
    stringr::regex(paste(vars, collapse = "|"),
      ignore_case = ignore_case
    )
  )]
}

#' Aggregate CIS episodes
#'
#' @description Aggregate CH variables by CHI and CIS.
#'
#'
#' @inheritParams create_individual_file
aggregate_ch_episodes_zihao <- function(episode_file) {
  cli::cli_alert_info("Aggregate ch episodes function started at {Sys.time()}")

  # Convert to data.table
  data.table::setDT(episode_file)

  # Perform grouping and aggregation
  episode_file <- episode_file[, `:=`(
    ch_no_cost = max(ch_no_cost),
    ch_ep_start = min(record_keydate1),
    ch_ep_end = max(ch_ep_end),
    ch_cost_per_day = mean(ch_cost_per_day)
  ), by = .(chi, ch_chi_cis)]

  # Convert back to tibble if needed
  episode_file <- tibble::as_tibble(episode_file)

  return(episode_file)
}
