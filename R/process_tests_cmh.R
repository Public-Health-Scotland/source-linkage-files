#' Process CMH tests
#'
#' @description This script takes the processed CMH extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_cmh <- function(data, year) {
  if (identical(data, tibble::tibble())) {
    # Deal with years where we have no data
    return(data)
  }

  data <- data %>%
    slfhelper::get_chi()

  old_data <- get_existing_data_for_tests(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_cmh_tests(old_data),
    new_data = produce_source_cmh_tests(data)
  ) %>%
    write_tests_xlsx(sheet_name = "cmh", year, workbook_name = "extract")

  return(comparison)
}

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
#'
#' @family extract test functions
#' @seealso [calculate_measures()]
produce_source_cmh_tests <- function(data) {
  test_flags <- data %>%
    # create test flags
    create_demog_test_flags(chi = .data$chi) %>%
    create_hb_test_flags(hb_var = .data$hbrescode) %>%
    dplyr::mutate(n_episodes = 1L) %>%
    # keep variables for comparison
    dplyr::select("unique_chi":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max <- data %>%
    calculate_measures(
      vars = c("record_keydate1", "record_keydate2"),
      measure = "min-max"
    )

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
