#' Care Home All Episodes Tests
#'
#' @description Produce the test for the Care Home all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_ch_episodes_path()])
#'
#' @return a dataframe with a count of each flag.
#'
#' @export
#' @family social care test functions
produce_sc_ch_episodes_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_missing_sending_loc = dplyr::if_else(is_missing(.data$sending_location), 1, 0),
      n_missing_sc_id = dplyr::if_else(is_missing(.data$social_care_id), 1, 0)
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
