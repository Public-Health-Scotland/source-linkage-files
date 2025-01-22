#' Process District Nursing tests
#'
#' @description This script takes the processed district nursing extract and
#' produces a test comparison with the previous data. This is written to
#' disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_district_nursing <- function(data, year) {
  if (identical(data, tibble::tibble())) {
    # Deal with years where we have no data
    return(data)
  }

  old_data <- get_existing_data_for_tests(data)
  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_dn_tests(old_data),
    new_data = produce_source_dn_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "dn", year, workbook_name = "extract")

  return(comparison)
}

#' Source District Nursing Tests
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
#' @param sum_mean_vars variables used when selecting 'all' measures
#' from [calculate_measures()]
#' @param max_min_vars variables used when selecting 'min-max'
#' from [calculate_measures()]
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' @seealso [create_hb_test_flags()], [create_hscp_test_flags()]
#' and [create_hb_cost_test_flags()] for creating test flags.
#' @seealso calculate_measures
produce_source_dn_tests <- function(data,
                                    sum_mean_vars = c("cost", "yearstay"),
                                    max_min_vars = c(
                                      "record_keydate1", "record_keydate2",
                                      "cost_total_net", "yearstay"
                                    )) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(.data$hbtreatcode, .data$cost_total_net) %>%
    # keep variables for comparison
    dplyr::select(.data$unique_anon_chi:.data$NHS_Lanarkshire_cost) %>%
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
