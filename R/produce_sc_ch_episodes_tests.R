#' Care Home All Epsiodes Tests
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
      .data$chi, .data$person_id, .data$gender, .data$dob, .data$postcode,
      .data$sending_location, .data$social_care_id, .data$ch_name,
      .data$ch_postcode, .data$record_keydate1, .data$record_keydate2,
      .data$ch_chi_cis, .data$ch_sc_id_cis, .data$ch_provider,
      .data$ch_nursing, .data$ch_adm_reason, .data$sc_latest_submission
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
