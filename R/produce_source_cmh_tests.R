#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by the CMH extract
#'
#' This will produce counts of various demographics.
#' It will also produce various summary statistics for episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#'
#' @family extract test functions
#' @seealso [calculate_measures()]
produce_source_cmh_tests <- function(data) {
  test_flags <- data %>%
    # create test flags
    create_demog_test_flags() %>%
    create_hb_test_flags(hb_var = .data$hbrescode) %>%
    dplyr::mutate(n_episodes = 1) %>%
    # keep variables for comparison
    dplyr::select(c(.data$valid_chi:.data$NHS_Lanarkshire)) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max <- data %>%
    calculate_measures(vars = c("record_keydate1", "record_keydate2"), measure = "min-max")

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
