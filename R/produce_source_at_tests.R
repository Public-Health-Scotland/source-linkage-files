#' Alarm Telecare Episodes Tests
#'
#' @description Produce the test for the Alarm Telecare all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_ch_episodes_path()])
#' @param max_min_vars variables used when selecting 'min-max' from [calculate_measures()]
#' @return a dataframe with a count of each flag.
#'
#' @export
#' @family social care test functions
produce_source_at_tests <- function(data, max_min_vars = c("record_keydate1", "record_keydate2")) {
  test_flags <- data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_at_alarms = dplyr::if_else(.data$smrtype == "AT-Alarm", 1, 0),
      n_at_telecare = dplyr::if_else(.data$smrtype == "AT-Tele", 1, 0)
    ) %>%
    create_lca_test_flags(.data$sc_send_lca) %>%
    # remove variables that won't be summed
    dplyr::select(.data$valid_chi:.data$West_Lothian) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max_measures <- data %>%
    calculate_measures(vars = max_min_vars, measure = "min-max")

  join_output <- list(test_flags, min_max_measures) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
