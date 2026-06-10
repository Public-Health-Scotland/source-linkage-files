#' Join SPARRA and HHG
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data including the SPARRA and HHG variables matched
#' on to the episode file.
join_sparra_hhg <- function(data,
                            year,
                            denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                            BYOC_MODE) {
  if (check_year_valid(year, "sparra")) {
    data <- dplyr::left_join(
      data,
      read_file(get_sparra_path(year)) %>%
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
      read_file(get_sparra_path(next_fy(year))),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_end_fy = NA_integer_)
  }

  if (check_year_valid(year, "hhg")) {
    data_hhg <- dplyr::tbl(denodo_connect, dbplyr::in_schema("sdl", "sdl_hhg")) %>%
      dplyr::filter(costs_financial_year == c_year) %>%
      dplyr::rename(hhg_start_fy = "hhg_score") %>%
      dplyr::collect()
    data <- dplyr::left_join(
      data,
      data_hhg,
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_start_fy = NA_integer_)
  }

  if (check_year_valid(next_fy(year), "hhg")) {
    data_hhg <- dplyr::tbl(denodo_connect, dbplyr::in_schema("sdl", "sdl_hhg")) %>%
      dplyr::filter(costs_financial_year == next_c_year) %>%
      dplyr::rename(hhg_end_fy = "hhg_score") %>%
      dplyr::collect()
    data <- dplyr::left_join(
      data,
      data_hhg,
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
