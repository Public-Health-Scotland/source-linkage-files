#' Produce Maternity tests
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#'
#' @family produce tests functions
#' @seealso [create_hb_test_flags()],
#' [create_hscp_test_flags()] and [create_hb_cost_test_flags()]
#' for creating test flags
produce_source_maternity_tests <- function(data) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(.data$hbtreatcode, .data$cost_total_net) %>%
    # keep variables for comparison
    dplyr::select(c(.data$valid_chi:.data$NHS_Lanarkshire_cost)) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  all_measures <- data %>%
    calculate_measures(vars = c("beddays", "cost", "yearstay"),
                       measure = "all")

  min_max <- data %>%
    calculate_measures(vars = c("record_keydate1", "record_keydate2", "cost_total_net", "yearstay"),
                       measure = "min-max")

  join_output <- list(
    test_flags,
    all_measures,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
