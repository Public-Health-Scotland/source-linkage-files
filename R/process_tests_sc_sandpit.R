#' Process tests for the social care sandpit extracts
#'
#' @param type Name of sandpit extract.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#' @export
#'
process_tests_sc_sandpit <- function(type = c("at", "hc", "ch", "sds", "demographics", "client"), year = NULL) {
  comparison <- produce_test_comparison(
    old_data = produce_sc_sandpit_tests(
      read_file(get_sandpit_extract_path(type = {{ type }}, year = year, update = previous_update())),
      type = {{ type }}
    ),
    new_data = produce_sc_sandpit_tests(
      read_file(get_sandpit_extract_path(type = {{ type }}, year = year, update = latest_update())),
      type = {{ type }}
    )
  )

  comparison %>%
    write_tests_xlsx(sheet_name = {{ type }}, year = year, workbook_name = "sandpit")

  return(comparison)
}


#' Produce tests for social care sandpit extracts.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_sandpit_extract_path()])
#' @param type Name of sandpit extract.
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#'
produce_sc_sandpit_tests <- function(data, type = c("demographics", "client", "at", "ch", "hc", "sds")) {
  if (type == "demographics") {
    missing_tests <- data %>%
      dplyr::mutate(
        n_missing_chi = is_missing(.data$chi_upi),
        n_missing_sc_id = is_missing(.data$social_care_id),
        n_missing_dob = is.na(.data$chi_date_of_birth),
        n_missing_postcode = is_missing(.data$chi_postcode),
        n_missing_gender = is_missing(.data$chi_gender_code)
      ) %>%
      dplyr::select(n_missing_chi:n_missing_gender) %>%
      calculate_measures(measure = "sum")

    latest_flag_tests <- data %>%
      dplyr::filter(!(is.na(.data$chi_upi))) %>%
      dplyr::group_by(.data$chi_upi, .data$sending_location) %>%
      dplyr::summarise(latest_count = sum(.data$latest_record_flag)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        chi_latest_flag_0 = dplyr::if_else(.data$latest_count == 0, 1, 0),
        chi_latest_flag_1 = dplyr::if_else(.data$latest_count == 1, 1, 0),
        chi_latest_flag_2 = dplyr::if_else(.data$latest_count == 2, 1, 0),
        chi_latest_flag_3 = dplyr::if_else(.data$latest_count == 3, 1, 0),
        chi_latest_flag_4 = dplyr::if_else(.data$latest_count == 4, 1, 0),
        chi_latest_flag_5 = dplyr::if_else(.data$latest_count == 5, 1, 0),
        chi_latest_flag_6 = dplyr::if_else(.data$latest_count == 6, 1, 0),
        chi_latest_flag_7 = dplyr::if_else(.data$latest_count == 7, 1, 0),
        chi_latest_flag_8 = dplyr::if_else(.data$latest_count == 8, 1, 0),
        chi_latest_flag_9 = dplyr::if_else(.data$latest_count == 9, 1, 0),
        chi_latest_flag_10 = dplyr::if_else(.data$latest_count == 10, 1, 0)
      ) %>%
      dplyr::select(.data$chi_latest_flag_0:.data$chi_latest_flag_10) %>%
      calculate_measures(measure = "sum")

    # add a flag for sc ids where there is multiple chi associated
    sc_id_multi_chi <- data %>%
      dplyr::distinct() %>%
      dplyr::filter(!(is.na(.data$chi_upi))) %>%
      dplyr::group_by(.data$social_care_id, .data$sending_location) %>%
      dplyr::distinct(.data$chi_upi, .keep_all = TRUE) %>%
      dplyr::mutate(distinct_chi_count = dplyr::n_distinct(.data$chi_upi)) %>%
      dplyr::filter(distinct_chi_count > 1) %>%
      dplyr::distinct(.data$social_care_id, .data$sending_location, .keep_all = TRUE) %>%
      dplyr::mutate(sc_id_multi_chi = 1) %>%
      create_sending_location_test_flags(.data$sending_location) %>%
      dplyr::ungroup() %>%
      dplyr::rename(
        sc_id_multi_chi_Aberdeen_City = Aberdeen_City,
        sc_id_multi_chi_Aberdeenshire = Aberdeenshire,
        sc_id_multi_chi_Angus = Angus,
        sc_id_multi_chi_Argyll_and_Bute = Argyll_and_Bute,
        sc_id_multi_chi_City_of_Edinburgh = City_of_Edinburgh,
        sc_id_multi_chi_Clackmannanshire = Clackmannanshire,
        sc_id_multi_chi_Dumfries_and_Galloway = Dumfries_and_Galloway,
        sc_id_multi_chi_Dundee_City = Dundee_City,
        sc_id_multi_chi_East_Ayrshire = East_Ayrshire,
        sc_id_multi_chi_East_Dunbartonshire = East_Dunbartonshire,
        sc_id_multi_chi_East_Lothian = East_Lothian,
        sc_id_multi_chi_East_Renfrewshire = East_Renfrewshire,
        sc_id_multi_chi_Falkirk = Falkirk,
        sc_id_multi_chi_Fife = Fife,
        sc_id_multi_chi_Glasgow_City = Glasgow_City,
        sc_id_multi_chi_Highland = Highland,
        sc_id_multi_chi_Inverclyde = Inverclyde,
        sc_id_multi_chi_Midlothian = Midlothian,
        sc_id_multi_chi_Moray = Moray,
        sc_id_multi_chi_Na_h_Eileanan_Siar = Na_h_Eileanan_Siar,
        sc_id_multi_chi_North_Ayrshire = North_Ayrshire,
        sc_id_multi_chi_North_Lanarkshire = North_Lanarkshire,
        sc_id_multi_chi_Orkney_Islands = Orkney_Islands,
        sc_id_multi_chi_Perth_and_Kinross = Perth_and_Kinross,
        sc_id_multi_chi_Renfrewshire = Renfrewshire,
        sc_id_multi_chi_Scottish_Borders = Scottish_Borders,
        sc_id_multi_chi_Shetland_Islands = Shetland_Islands,
        sc_id_multi_chi_South_Ayrshire = South_Ayrshire,
        sc_id_multi_chi_South_Lanarkshire = South_Lanarkshire,
        sc_id_multi_chi_Stirling = Stirling,
        sc_id_multi_chi_West_Dunbartonshire = West_Dunbartonshire,
        sc_id_multi_chi_West_Lothian = West_Lothian
      ) %>%
      dplyr::select(.data$sc_id_multi_chi, .data$sc_id_multi_chi_Aberdeen_City:.data$sc_id_multi_chi_West_Lothian) %>%
      calculate_measures(measure = "sum")

    output <- list(
      missing_tests,
      latest_flag_tests,
      sc_id_multi_chi
    ) %>%
      purrr::reduce(dplyr::full_join, by = c("measure", "value"))

    return(output)
  } else if (type == "client" | type == "at" | type == "ch" |
    type == "hc" | type == "sds") {
    output <- data %>%
      # create test flags
      dplyr::mutate(
        unique_scid = dplyr::lag(.data$social_care_id) != .data$social_care_id,
        n_missing_scid = is_missing(.data$social_care_id)
      ) %>%
      create_sending_location_test_flags(.data$sending_location) %>%
      # remove variables that won't be summed
      dplyr::select(c("unique_scid":"West_Lothian")) %>%
      # use function to sum new test flags
      calculate_measures(measure = "sum")

    return(output)
  }
}
