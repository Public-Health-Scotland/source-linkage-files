#' Process Social Care Care Home all episodes tests
#'
#' @param data The processed Care Home all episode data produced by
#' [process_extract_care_home()].
#'
#' @description This script takes the processed all Care Home file and produces
#' a test comparison with the previous data.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_sc_ch_episodes <- function(data) {
  comparison <- produce_test_comparison(
    old_data = produce_sc_ch_episodes_tests(
      readr::read_rds(get_sc_ch_episodes_path(update = previous_update()))
    ),
    new_data = produce_sc_ch_episodes_tests(
      data
    )
  )

  comparison %>%
    write_tests_xlsx(sheet_name = "all_ch_episodes")

  return(comparison)
}

#' Care Home All Episodes Tests
#'
#' @description Produce the test for the Care Home all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_ch_episodes_path()])
#'
#' @return a dataframe with a count of each flag.
#'
#' @family social care test functions
produce_sc_ch_episodes_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_missing_sending_loc = dplyr::if_else(
        is_missing(.data$sending_location),
        1L,
        0L
      ),
      n_missing_sc_id = dplyr::if_else(
        is_missing(.data$social_care_id),
        1L,
        0L
      )
    ) %>%
    # remove variables that won't be summed
    dplyr::select(-c(
      "chi", "person_id", "gender", "dob", "postcode",
      "sending_location", "social_care_id", "ch_name",
      "ch_postcode", "record_keydate1", "record_keydate2",
      "ch_chi_cis", "ch_sc_id_cis", "ch_provider",
      "ch_nursing", "ch_adm_reason", "sc_latest_submission"
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
