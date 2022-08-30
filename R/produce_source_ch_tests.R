#' Source Care Home Tests
#'
#' @description Produce a set of tests which can be used by Care Home
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbtreatcode`
#' using [create_lca_test_flags()]
#' It will also produce various summary statistics for bedday, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#' @param sum_mean_vars variables used when selecting 'all' measures from [calculate_measures()]
#' @param max_min_vars variables used when selecting 'min-max' from [calculate_measures()]
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#'
#' @family extract test functions
#' @seealso calculate_measures
produce_source_ch_tests <- function(data,
                                         sum_mean_vars = c("beddays", "cost", "yearstay"),
                                         max_min_vars = c(
                                           "record_keydate1", "record_keydate2",
                                           "cost_total_net", "yearstay"
                                         )) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    # create_hb_test_flags(.data$hbtreatcode) %>%
    # create_hb_cost_test_flags(.data$hbtreatcode, .data$cost_total_net) %>%
    dplyr::mutate(n_episodes = 1) %>%
    create_lca_test_flags(., sc_send_lca) %>%
    # keep variables for comparison
    dplyr::select(c(.data$valid_chi:.data$West_Lothian)) %>%
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
