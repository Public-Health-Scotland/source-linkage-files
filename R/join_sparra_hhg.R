#' Join SPARRA and HHG
#'
#' @inheritParams store_ep_file_vars
#'
#' @return The data including the SPARRA and HHG variables matched
#' on to the episode file.
join_sparra_hhg <- function(data, year) {
  if (check_year_valid(year, "SPARRA")) {
    data <- dplyr::left_join(
      data,
      read_file(get_sparra_path(year)) %>%
        dplyr::rename(sparra_start_fy = "sparra_risk_score"),
      by = c("chi", "upi_number"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_start_fy = NA_real_)
  }

  if (check_year_valid(next_fy(year), "SPARRA")) {
    data <- dplyr::left_join(
      data,
      read_file(get_sparra_path(year)) %>%
        dplyr::rename(sparra_end_fy = "sparra_risk_score"),
      by = c("chi", "upi_number"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, sparra_end_fy = NA_real_)
  }

  if (check_year_valid(year, "HHG")) {
    data <- dplyr::left_join(
      data,
      read_file(get_sparra_path(year)) %>%
        dplyr::rename(hhg_start_fy = "hhg_score"),
      by = c("chi", "upi_number"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_start_fy = NA_real_)
  }

  if (check_year_valid(next_fy(year), "HHG")) {
    data <- dplyr::left_join(
      data,
      read_file(get_sparra_path(year)) %>%
        dplyr::rename(hhg_end_fy = "hhg_score"),
      by = c("chi", "upi_number"),
      na_matches = "never",
      relationship = "many-to-one"
    )
  } else {
    data <- dplyr::mutate(data, hhg_end_fy = NA_real_)
  }

  return(data)
}
