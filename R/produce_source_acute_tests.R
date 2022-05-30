#' Produce the Source Extract tests
#'
#' @description Produce a set of tests which can be used by most
#' of the extracts. 
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbtreatcode`
#' using [create_hb_test_flags()], a total cost for each `hbtreatcode` using
#' [create_hb_cost_test_flags()]. 
#' It will also produce various summary statistics for bedday, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from \code{\link{get_source_extract_path}})
#'
#' @return a dataframe with a count of each flag
#' from \code{\link{calculate_measures}}
#' @export
#'
#' @family produce tests functions
#' @seealso \code{\link{create_hb_test_flags}},
#' \code{\link{create_hscp_test_flags}} and \code{\link{create_hb_cost_test_flags}}
#' for creating test flags
produce_source_extract_tests <- function(data) {
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
    calculate_measures(vars = c("beddays", "cost", "yearstay"), measure = "all")

  min_max <- data %>%
    calculate_measures(vars = c("record_keydate1", "record_keydate2", "cost_total_net", "yearstay"), measure = "min-max")

  join_output <- list(
    test_flags,
    all_measures,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
