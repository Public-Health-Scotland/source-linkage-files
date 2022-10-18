#' Alarm Telecare and SDS Episodes Tests
#'
#' @description Produce the test for the Alarm Telecare and SDS all episodes
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sc_ch_episodes_path()])
#'
#' @return a dataframe with a count of each flag.
#'
#' @export
#' @family social care test functions
produce_source_at_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      n_missing_sending_loc = dplyr::if_else(is_missing(.data$sc_send_lca), 1, 0),
      n_missing_person_id = dplyr::if_else(is_missing(.data$person_id), 1, 0)
    ) %>%
    # remove variables that won't be summed
    dplyr::select(
      -c(
        .data$chi,
        .data$person_id,
        .data$gender,
        .data$dob,
        .data$postcode,
        .data$record_keydate1,
        .data$record_keydate2,
        .data$sc_latest_submission,
        .data$year,
        .data$recid,
        .data$smrtype,
        .data$sc_send_lca
      )
    ) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
