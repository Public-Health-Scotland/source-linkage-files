#' Process Alarms Telecare tests
#'
#' @description This script takes the processed Alarms Telecare extract and
#' produces a test comparison with the previous data. This is written to
#' disk as a CSV.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_alarms_telecare <- function(data, year) {
  old_data <- get_existing_data_for_tests(data)

  data <- rename_hscp(data)

  comparison <- produce_test_comparison(
    old_data = produce_source_at_tests(old_data),
    new_data = produce_source_at_tests(data)
  )

  comparison %>%
    write_tests_xlsx(sheet_name = "at", year, workbook_name = "extract")

  return(comparison)
}

#' Alarm Telecare Episodes Tests
#'
#' @description Produce the test for the Alarm Telecare all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_ch_episodes_path()])
#' @param max_min_vars variables used when selecting 'min-max' from [calculate_measures()]
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_source_at_tests <- function(data,
                                    max_min_vars = c("record_keydate1", "record_keydate2")) {
  # count of NA before applying distinct count which makes NA == 1
  n_missing_chi_total <- sum(is.na(data$anon_chi))

  test_flags <- data %>%
    dplyr::arrange(.data$anon_chi) %>%
    dplyr::distinct(.data$anon_chi, .data$social_care_id, .keep_all = TRUE) %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_at_alarms = .data$smrtype == "AT-Alarm",
      n_at_telecare = .data$smrtype == "AT-Tele"
    ) %>%
    create_lca_client_test_flags(.data$sc_send_lca) %>%
    # remove variables that won't be summed
    dplyr::select(.data$unique_anon_chi:.data$West_Lothian_clients) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum") %>%
    # replace distinct n_missing_chi with the correct sum of NAs
    dplyr::mutate(value = dplyr::if_else(measure == "n_missing_chi", as.numeric(n_missing_chi_total), value))

  min_max_measures <- data %>%
    calculate_measures(vars = max_min_vars, measure = "min-max")

  join_output <- list(test_flags, min_max_measures) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
