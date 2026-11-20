#' Join SPARRA and HHG
#'
#' @param sparra_data the data for SPARRA from Denodo
#' @param sparra_next_fy_data SPARRA dataset for the next FY
#' @param hhg_data the HHG dataset
#' @param hhg_next_fy_data HHG dataset for the next FY
#' @param BYOC_MODE BYOC_MODE
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
                            sparra_next_fy_data = get_sparra_data(
                              year = next_fy(year),
                              denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                              BYOC_MODE = BYOC_MODE
                            ),
                            hhg_data = get_hhg_data(year,
                              denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                              BYOC_MODE = BYOC_MODE
                            ),
                            hhg_next_fy_data = get_hhg_data(
                              year = next_fy(year),
                              denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                              BYOC_MODE = BYOC_MODE
                            ),
                            BYOC_MODE = BYOC_MODE) {
  if (check_year_valid(year, "sparra") && nrow(sparra_data) > 0) {
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

  if (check_year_valid(next_fy(year), "sparra") && nrow(sparra_data) > 0) {
    data <- dplyr::left_join(
      data,
      sparra_next_fy_data %>%
        dplyr::select(anon_chi, sparra_risk_score) %>%
        dplyr::rename(sparra_end_fy = "sparra_risk_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_end_fy = NA_integer_)
  }

  if (check_year_valid(year, "hhg") && nrow(hhg_data) > 0) {
    data <- dplyr::left_join(
      data,
      hhg_data %>%
        dplyr::select(anon_chi, hhg_score) %>%
        dplyr::rename(hhg_start_fy = "hhg_score"),
      by = c("anon_chi"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_start_fy = NA_integer_)
  }

  if (check_year_valid(next_fy(year), "hhg") && nrow(hhg_data) > 0) {
    data <- dplyr::left_join(
      data,
      hhg_next_fy_data %>%
        dplyr::select(anon_chi, hhg_score) %>%
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
