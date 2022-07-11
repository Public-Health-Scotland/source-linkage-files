#' Source PIS Tests
#'
#' @description Produce a set of tests which can be used by most
#' of the extracts.
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbtreatcode`
#' It will also produce various summary statistics for beddays, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#' @param sum_mean_vars variables used when selecting 'all' measures from [calculate_measures()]
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#'
#' @family extract test functions
#' for creating test flags
#' @seealso calculate_measures
produce_source_pis_tests <- function(data,
                                     sum_mean_vars = c("beddays", "cost", "yearstay")) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    mutate(n_episodes = 1) %>%
    # keep variables for comparison
    dplyr::select(c(.data$valid_chi:.data$n_episodes)) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  all_measures <- data %>%
    calculate_measures(vars = {{ sum_mean_vars }}, measure = "all")

  join_output <- list(
    test_flags,
    all_measures
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
