#' LTC Episodes Tests
#'
#' @description Produce the test for the Long Term Conditions (LTCs) all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_ltcs_path()]
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_source_ltc_tests <- function(data) {
  ltc_vars <- slfhelper::ltc_vars
  ltc_vars2 <- c("anon_chi", ltc_vars)
  ltc_dates <- paste0(ltc_vars, "_date")

  join_output <- data %>%
    dplyr::summarise(
      chi = nrow(data),
      unique_chi = dplyr::n_distinct(.data$anon_chi),
      # Sum each LTC variable
      dplyr::across(dplyr::all_of(ltc_vars), ~ sum(.x, na.rm = TRUE))
    ) %>%
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "measure",
      values_to = "value"
    )

  return(join_output)
}
