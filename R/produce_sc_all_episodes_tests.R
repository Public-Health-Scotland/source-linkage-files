#' Social care All Episodes Tests
#'
#' @description Produce the test for the social care all episodes
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_sc_all_episodes_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_missing_sending_loc = dplyr::if_else(
        is.na(.data$sending_location),
        1L,
        0L
      ),
      n_missing_sc_id = dplyr::if_else(
        is_missing(.data$social_care_id),
        1L,
        0L
      )
    ) %>%
    # keep variables for comparison
    dplyr::select(c("unique_anon_chi":dplyr::last_col())) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
