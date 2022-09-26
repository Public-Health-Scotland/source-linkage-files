#' SLF long term conditions (LTC) Lookup Tests
#'
#' @description Produce the tests for the LTC Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_ltc_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#' @family slf test functions
produce_slf_ltc_tests <- function(data) {
  data %>%
    # create test flags
    dplyr::mutate(
      n_chi = 1
    ) %>%
    dplyr::select(.data$n_chi, .data$arth:.data$digestive) %>%
    calculate_measures(measure = "sum")
}
