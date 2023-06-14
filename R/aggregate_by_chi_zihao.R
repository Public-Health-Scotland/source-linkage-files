#' Aggregate by CHI
#'
#' @description Aggregate episode file by CHI to convert into
#' individual file.
#'
#' @importFrom data.table .N
#' @importFrom data.table .SD
#'
#' @inheritParams create_individual_file
aggregate_by_chi_zihao <- function(episode_file) {
  cli::cli_alert_info("Aggregate by CHI function started at {Sys.time()}")

  episode_file <- episode_file %>%
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

  names(episode_file) <- tolower(names(episode_file))

  data.table::setDT(episode_file) # Convert to data.table

  # Sort the data within each chunk
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

  data.table::setnames(
    episode_file,
    c(
      "ch_chi_cis", "cij_marker", "ooh_case_id"
      # ,"hh_in_fy"
    ),
    c(
      "ch_cis_episodes", "cij_total", "ooh_cases"
      # ,"hl1_in_fy"
    )
  )

  # Initialize an empty data.table for the aggregated results
  aggregated_data <- data.table::data.table()

  # Process the data in chunks
  chunk_size <- min(nrow(episode_file), 5e7)
  # Adjust the chunk size as per your system's memory capacity
  n_chunks <- nrow(episode_file) %/% chunk_size


  # colums specification
  # columns to select last
  cols2 <- vars_end_with(
    episode_file,
    c("postcode", "dob", "ggprac")
  )
  # columns to select last unique rows
  cols3 <- c(
    "ch_cis_episodes",
    "cij_total",
    "cij_el",
    "cij_non_el",
    "cij_mat",
    # "cij_delay",
    "ooh_cases",
    "preventable_admissions",
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
    vars_start_with(episode_file, "sc_")
  )
  # columns to sum up
  cols4 <- c(
    vars_end_with(
      episode_file,
      c(
        "episodes",
        "beddays",
        "cost",
        "attendances",
        "attend",
        # "contacts",
        "hours",
        "alarms",
        "telecare",
        "paid_items",
        "advice",
        "homev",
        "time",
        "assessment",
        "other",
        # "dn",
        "nhs24",
        "pcc",
        "_dnas"
      )
    ),
    vars_start_with(
      episode_file,
      "sds_option"
    )
  )
  cols4 <- cols4[!(cols4 %in% c("ch_cis_episodes"))]
  # # columns to select maximum
  # cols5 <- vars_contain(episode_file, "nsu")
  # columns to select first row
  cols6 <- c(
    condition_cols(),
    # "death_date",
    # "deceased",
    "year",
    vars_end_with(
      episode_file,
      c("_cohort", "end_fy", "start_fy")
    )
  )

  for (i in 1:n_chunks) {
    start <- (i - 1) * chunk_size + 1
    end <- i * chunk_size
    # Subset the data to the current chunk
    chunk <- episode_file[start:end]

    # compute
    chunk_cols1 <- chunk[,
      .(gender = mean(gender)),
      by = chi
    ]
    chunk_cols2 <- chunk[,
      .SD[.N],
      .SDcols = cols2,
      by = chi
    ]
    chunk_cols3 <- chunk[,
      lapply(.SD, function(x) {
        data.table::uniqueN(x, na.rm = TRUE)
      }),
      .SDcols = cols3,
      by = chi
    ]
    chunk_cols4 <- chunk[,
      lapply(.SD, function(x) {
        sum(x, na.rm = TRUE)
      }),
      .SDcols = cols4,
      by = chi
    ]
    # chunk_cols5 <- chunk[,
    #                      lapply(.SD, function(x) max(x, na.rm = TRUE)),
    #                      .SDcols = cols5,
    #                      by = chi]
    chunk_cols6 <- chunk[,
      lapply(.SD, function(x) {
        x[!is.na(x)][1]
      }),
      .SDcols = cols6,
      by = chi
    ]
    chunk_agg <- dplyr::bind_cols(
      chunk_cols1,
      chunk_cols2[, chi := NULL],
      chunk_cols3[, chi := NULL],
      chunk_cols4[, chi := NULL],
      # chunk_cols5[, chi := NULL],
      chunk_cols6[, chi := NULL]
    )

    # Append the aggregated chunk to the overall result
    aggregated_data <-
      data.table::rbindlist(list(aggregated_data, chunk_agg))
  }
  aggregated_data <- dplyr::as_tibble(aggregated_data)

  return(aggregated_data)
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
