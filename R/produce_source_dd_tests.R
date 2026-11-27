#' Delayed Discharges extract tests
#'
#' @description Produce tests for the delayed discharges extract.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' for creating test flags
#' @seealso calculate_measures
produce_source_dd_tests <- function(data) {
  test_flags <- data %>%
    dplyr::mutate(
      n_delay_episodes = 1L,
      code9_episodes = .data$primary_delay_reason == "9"
    ) %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    # keep variables for comparison
    dplyr::select(c("n_delay_episodes":dplyr::last_col())) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  return(test_flags)
}
