#' Source Extract Tests
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
#' (data is from [get_source_extract_path()])
#' @param sum_mean_vars variables used when selecting 'all' measures from [calculate_measures()]
#' @param max_min_vars variables used when selecting 'min-max' from [calculate_measures()]
#' @param add_hscp_count  Default set to TRUE. For use where `hscp variable` is not available, specify FALSE.
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#'
#' @family extract test functions
#' @seealso [create_hb_test_flags()],
#' [create_hscp_test_flags()] and [create_hb_cost_test_flags()]
#' for creating test flags
#' @seealso calculate_measures
produce_source_extract_tests <- function(data,
                                         sum_mean_vars = c("beddays", "cost", "yearstay"),
                                         max_min_vars = c(
                                           "record_keydate1", "record_keydate2",
                                           "cost_total_net", "yearstay"
                                         ),
                                         add_hscp_count = TRUE) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags(chi = .data$chi) %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(.data$hbtreatcode, .data$cost_total_net)

  if (add_hscp_count) {
    test_flags <- create_hscp_test_flags(test_flags, .data$hscp2018)
  }

  test_flags <- test_flags %>%
    # keep variables for comparison
    dplyr::select("unique_chi":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  all_measures <- data %>%
    calculate_measures(vars = {{ sum_mean_vars }}, measure = "all")

  min_max <- data %>%
    calculate_measures(vars = {{ max_min_vars }}, measure = "min-max")

  join_output <- list(
    test_flags,
    all_measures,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
