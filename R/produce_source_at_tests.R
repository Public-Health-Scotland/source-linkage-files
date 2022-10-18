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
produce_source_at_tests <- function(data, max_min_vars = c("record_keydate1", "record_keydate2")) {
  test_flags <- data %>%
    # create test flags
    create_demog_test_flags() %>%
    dplyr::mutate(
      sc_living_alone_no = dplyr::if_else(.data$sc_living_alone == 0, 1, 0),
      sc_living_alone_yes = dplyr::if_else(.data$sc_living_alone == 1, 1, 0),
      sc_living_alone_unknown = dplyr::if_else(.data$sc_living_alone == 9, 1, 0),

      sc_support_from_unpaid_carer_no = dplyr::if_else(.data$sc_support_from_unpaid_carer == 0, 1, 0),
      sc_support_from_unpaid_carer_yes = dplyr::if_else(.data$sc_support_from_unpaid_carer == 1, 1, 0),
      sc_support_from_unpaid_carer_unknown = dplyr::if_else(.data$sc_support_from_unpaid_carer == 9, 1, 0),

      sc_social_worker_no = dplyr::if_else(.data$sc_social_worker == 0, 1, 0),
      sc_social_worker_yes = dplyr::if_else(.data$sc_social_worker == 1, 1, 0),
      sc_social_worker_unknown = dplyr::if_else(.data$sc_social_worker == 9, 1, 0),

      sc_meals_no = dplyr::if_else(.data$sc_meals == 0, 1, 0),
      sc_meals_yes = dplyr::if_else(.data$sc_meals == 1, 1, 0),
      sc_meals_unknown = dplyr::if_else(.data$sc_meals == 9, 1, 0),

      sc_day_care_no = dplyr::if_else(.data$sc_day_care == 0, 1, 0),
      sc_day_care_yes = dplyr::if_else(.data$sc_day_care == 1, 1, 0),
      sc_day_care_unknown = dplyr::if_else(.data$sc_day_care == 9, 1, 0),

      sc_housing_mainstream = dplyr::if_else(.data$sc_type_of_housing == 1, 1, 0),
      sc_housing_supported = dplyr::if_else(.data$sc_type_of_housing == 2, 1, 0),
      sc_housing_longstaych = dplyr::if_else(.data$sc_type_of_housing == 3, 1, 0),
      sc_housing_hospital = dplyr::if_else(.data$sc_type_of_housing == 4, 1, 0),
      sc_housing_other = dplyr::if_else(.data$sc_type_of_housing == 5, 1, 0),
      sc_housing_unknown = dplyr::if_else(.data$sc_type_of_housing == 6, 1, 0),

      n_missing_sending_loc = dplyr::if_else(is_missing(.data$sc_send_lca), 1, 0),
      n_missing_person_id = dplyr::if_else(is_missing(.data$person_id), 1, 0),
      n_at_alarms = dplyr::if_else(smrtype == "AT-Alarm", 1, 0),
      n_at_telecare = dplyr::if_else(smrtype == "AT-Tele", 1, 0)
    ) %>%
    create_lca_test_flags(sc_send_lca) %>%
    # remove variables that won't be summed
    dplyr::select(.data$valid_chi:.data$West_Lothian) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max_measures <- data %>%
    calculate_measures(vars = max_min_vars, measure = "min-max")

  join_output <- list(test_flags, min_max_measures) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
