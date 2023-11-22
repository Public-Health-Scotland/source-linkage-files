#' Process the all SDS extract
#' @description This will read and process the
#' all SDS extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_sc_all_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
#' @export
#'
process_sc_all_sds <- function(
    data,
    sc_demog_lookup,
    write_to_disk = TRUE) {
  # Match on demographics data (chi, gender, dob and postcode)
  matched_sds_data <- data %>%
    dplyr::left_join(
      sc_demog_lookup,
      by = c("sending_location", "social_care_id")
    ) %>%
    # when multiple social_care_id from sending_location for single CHI
    # replace social_care_id with latest
    replace_sc_id_with_latest()

  # Data Cleaning ---------------------------------------
  sds_full_clean <- matched_sds_data %>%
    # Deal with SDS option 4
    # First turn the option flags into a logical T/F
    dplyr::mutate(dplyr::across(
      tidyselect::starts_with("sds_option_"),
      ~ dplyr::case_when(
        .x == 1L ~ TRUE,
        .x == 0L ~ FALSE,
        is.na(.x) ~ FALSE
      )
    )) %>%
    # SDS option 4 is derived when a person receives more than one option.
    # e.g. if a person has options 1 and 2 then option 4 will be derived
    dplyr::mutate(
      sds_option_4 = rowSums(
        dplyr::pick(tidyselect::starts_with("sds_option_"))
      ) > 1L,
      .after = .data$sds_option_3
    ) %>%
    # If SDS start date is missing, assign start of FY
    dplyr::mutate(
      sds_start_date = fix_sc_start_dates(
        .data$sds_start_date,
        .data$sds_period_start_date
      ),
      # If SDS end date is missing, assign end of FY
      sds_end_date = fix_sc_missing_end_dates(
        .data$sds_end_date,
        .data$sds_period_end_date
      ),
      # Fix sds_end_date is earlier than sds_start_date by setting end_date to be the end of fyear
      sds_end_date = fix_sc_end_dates(
        .data$sds_start_date,
        .data$sds_end_date,
        .data$period
      )
    ) %>%
    # rename for matching source variables
    dplyr::rename(
      record_keydate1 = .data$sds_start_date,
      record_keydate2 = .data$sds_end_date
    ) %>%
    # Pivot longer on sds option variables
    tidyr::pivot_longer(
      cols = tidyselect::contains("sds_option_"),
      names_to = "sds_option",
      names_prefix = "sds_option_",
      names_transform = list(sds_option = ~ paste0("SDS-", .x)),
      values_to = "received"
    ) %>%
    # Only keep rows where they received a package and remove duplicates
    dplyr::filter(.data$received) %>%
    dplyr::distinct() %>%
    # Include source variables
    dplyr::mutate(
      smrtype = dplyr::case_when(
        sds_option == "SDS-1" ~ "SDS-1",
        sds_option == "SDS-2" ~ "SDS-2",
        sds_option == "SDS-3" ~ "SDS-3",
        sds_option == "SDS-4" ~ "SDS-4"
      ),
      recid = "SDS",
      # Create person id variable
      person_id = stringr::str_glue("{sending_location}-{social_care_id}"),
      # Use function for creating sc send lca variables
      sc_send_lca = convert_sc_sending_location_to_lca(.data$sending_location)
    ) %>%
    # when multiple social_care_id from sending_location for single CHI
    # replace social_care_id with latest
    replace_sc_id_with_latest()

  final_data <- sds_full_clean %>%
    # use as.data.table to change the data format to data.table to accelerate
    data.table::as.data.table() %>%
    dplyr::group_by(
      .data$sending_location,
      .data$social_care_id,
      .data$smrtype
    ) %>%
    dplyr::arrange(.data$period,
      .data$record_keydate1,
      .by_group = TRUE
    ) %>%
    # Create a flag for episodes that are going to be merged
    # Create an episode counter
    dplyr::mutate(
      distinct_episode = (.data$record_keydate1 > dplyr::lag(.data$record_keydate2)) %>%
        tidyr::replace_na(TRUE),
      episode_counter = cumsum(.data$distinct_episode)
    ) %>%
    # Group by episode counter and merge episodes
    dplyr::group_by(.data$episode_counter, .add = TRUE) %>%
    dplyr::summarise(
      sc_latest_submission = dplyr::last(.data$period),
      record_keydate1 = min(.data$record_keydate1),
      record_keydate2 = max(.data$record_keydate2),
      sending_location = dplyr::last(.data$sending_location),
      social_care_id = dplyr::last(.data$social_care_id),
      chi = dplyr::last(.data$chi),
      gender = dplyr::last(.data$gender),
      dob = dplyr::last(.data$dob),
      postcode = dplyr::last(.data$postcode),
      recid = dplyr::last(.data$recid),
      person_id = dplyr::last(.data$person_id),
      sc_send_lca = dplyr::last(.data$sc_send_lca)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-.data$episode_counter) %>%
    # change the data format from data.table to data.frame
    tibble::as_tibble()

  if (write_to_disk) {
    write_file(
      final_data,
      get_sc_sds_episodes_path(check_mode = "write")
    )
  }

  return(final_data)
}
