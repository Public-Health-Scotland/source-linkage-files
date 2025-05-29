#' Join SPARRA and HHG
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data including the SPARRA and HHG variables matched
#' on to the episode file.
join_sparra_hhg <- function(data, year) {
  if (check_year_valid(year, "sparra")) {
    data <- dplyr::left_join(
      data,
      read_file(get_sparra_path(year) %>%
        dplyr::mutate(sparra_start_fy = as.numeric(sparra_start_fy))) %>%
        dplyr::rename(sparra_start_fy = "sparra_risk_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_start_fy = as.numeric(sparra_start_fy))
  }

  if (check_year_valid(next_fy(year), "sparra")) {
    data <- dplyr::left_join(
      data,
      read_file(get_sparra_path(next_fy(year)) %>%
        dplyr::mutate(sparra_end_fy = as.integer(sparra_end_fy))) %>%
        dplyr::rename(sparra_end_fy = "sparra_risk_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_end_fy = as.integer(sparra_end_fy))
  }

  if (check_year_valid(year, "hhg")) {
    data <- dplyr::left_join(
      data,
      read_file(get_hhg_path(year) %>%
        dplyr::mutate(hhg_start_fy = as.integer(hhg_start_fy))) %>%
        dplyr::rename(hhg_start_fy = "hhg_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_start_fy = as.integer(hhg_start_fy))
  }

  if (check_year_valid(next_fy(year), "hhg")) {
    data <- dplyr::left_join(
      data,
      read_file(get_hhg_path(next_fy(year)) %>%
        dplyr::mutate(hhg_end_fy = as.numeric(hhg_end_fy))) %>%
        dplyr::rename(hhg_end_fy = "hhg_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_end_fy = as.numeric(hhg_end_fy))
  }

  cli::cli_alert_info("Join SPARRA and HHG function finished at {Sys.time()}")

  return(data)
}
