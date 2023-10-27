#' Process Care Home tests
#'
#' @description This script takes the processed Care home extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_care_home <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  if ("hscp" %in% names(data)) {
    data <- data %>%
      dplyr::rename("hscp2018" = "hscp")
  } else {
    data <- data
  }

  comparison <- produce_test_comparison(
    old_data = produce_source_ch_tests(old_data),
    new_data = produce_source_ch_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "CH", year, workbook_name = "extract")

  return(comparison)
}

#' Source Care Home Tests
#'
#' @description Produce a set of tests which can be used by Care Home and Home Care
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
    dplyr::mutate(
      n_episodes = 1L,
      ch_name_missing = is.na(.data$ch_name),
      ch_provider_1_to_5 = dplyr::case_when(
        .data$ch_provider %in% c("1", "2", "3", "4", "5") ~ 1L,
        TRUE ~ 0L
      ),
      ch_provider_other = .data$ch_provider == "6",
      ch_adm_reason_missing = is.na(.data$ch_adm_reason)
    ) %>%
    create_lca_test_flags(.data$sc_send_lca) %>%
    # keep variables for comparison
    dplyr::select("valid_chi":dplyr::last_col()) %>%
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
