#' Join SPARRA and HHG
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data including the SPARRA and HHG variables matched
#' on to the episode file.
join_sparra_hhg <- function(data,
                            year,
                            sparra_data = get_sparra_data(year,
                              denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                              BYOC_MODE = BYOC_MODE
                            ),
                            hhg_data = get_hhg_data(year,
                              denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                              BYOC_MODE = BYOC_MODE
                            ),
                            BYOC_MODE = BYOC_MODE) {
  if (check_year_valid(year, "sparra")) {
    data <- dplyr::left_join(
      data,
      sparra_data %>%
        dplyr::select(anon_chi, sparra_risk_score) %>%
        dplyr::rename(sparra_start_fy = "sparra_risk_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_start_fy = NA_integer_)
  }

  if (check_year_valid(next_fy(year), "sparra")) {
    data <- dplyr::left_join(
      data,
      get_sparra_data(next_fy(year), denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE), BYOC_MODE = BYOC_MODE) %>%
        dplyr::select(anon_chi, sparra_risk_score) %>%
        dplyr::rename(sparra_end_fy = "sparra_risk_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_end_fy = NA_integer_)
  }

  if (check_year_valid(year, "hhg")) {
    data <- dplyr::left_join(
      data,
      hhg_data %>%
        dplyr::rename(hhg_start_fy = "hhg_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_start_fy = NA_integer_)
  }

  if (check_year_valid(next_fy(year), "hhg")) {
    data <- dplyr::left_join(
      data,
      get_hhg_data(next_fy(year), denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE), BYOC_MODE = BYOC_MODE) %>%
        dplyr::rename(hhg_end_fy = "hhg_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_end_fy = NA_integer_)
  }

  cli::cli_alert_info("Join SPARRA and HHG function finished at {Sys.time()}")

  return(data)
}
