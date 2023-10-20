#' Process the all Alarms Telecare extract
#'
#' @description This will read and process the
#' all Alarms Telecare extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_sc_all_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
#' @export
#'
process_sc_all_alarms_telecare <- function(
    data,
    sc_demog_lookup,
    write_to_disk = TRUE) {
  # Data Cleaning-----------------------------------------------------

  replaced_dates <- data %>%
    # period start and end dates
    dplyr::mutate(
      record_date = end_fy_quarter(.data$period),
      qtr_start = start_fy_quarter(.data$period)
    ) %>%
    dplyr::mutate(service_start_date = fix_sc_start_dates(
      .data$service_start_date,
      .data$period
    )) %>%
    # Fix service_end_date is earlier than service_start_date by setting end_date to the end of fy
    dplyr::mutate(service_end_date = fix_sc_end_dates(
      .data$service_start_date,
      .data$service_end_date,
      .data$period
    ))

  at_full_clean <- replaced_dates %>%
    # Match on demographics data (chi, gender, dob and postcode)
    dplyr::left_join(
      sc_demog_lookup,
      by = c("sending_location", "social_care_id")
    ) %>%
    # rename for matching source variables
    dplyr::rename(
      record_keydate1 = .data$service_start_date,
      record_keydate2 = .data$service_end_date
    ) %>%
    # Include source variables
    dplyr::mutate(
      recid = "AT",
      smrtype = dplyr::case_when(
        .data$service_type == 1L ~ "AT-Alarm",
        .data$service_type == 2L ~ "AT-Tele"
      ),
      # Create person id variable
      person_id = stringr::str_glue("{sending_location}-{social_care_id}"),
      # Use function for creating sc send lca variables
      sc_send_lca = convert_sc_sending_location_to_lca(.data$sending_location)
    ) %>%
    # when multiple social_care_id from sending_location for single CHI
    # replace social_care_id with latest
    dplyr::group_by(.data$sending_location, .data$chi) %>%
    dplyr::mutate(latest_sc_id = dplyr::last(.data$social_care_id)) %>%
    # count changed social_care_id
    dplyr::mutate(
      changed_sc_id = !is.na(.data$chi) & .data$social_care_id != .data$latest_sc_id,
      social_care_id = dplyr::if_else(.data$changed_sc_id, .data$latest_sc_id, .data$social_care_id)
    ) %>%
    dplyr::ungroup()

  # Deal with episodes which have a package across quarters.
  qtr_merge <- at_full_clean %>%
    # use as.data.table to change the data format to data.table to accelerate
    data.table::as.data.table() %>%
    dplyr::group_by(
      .data$sending_location,
      .data$social_care_id,
      .data$record_keydate1,
      .data$smrtype,
      .data$period
    ) %>%
    # Create a count for the package number across episodes
    dplyr::mutate(pkg_count = dplyr::row_number()) %>%
    # Sort prior to merging
    dplyr::arrange(.by_group = TRUE) %>%
    # group for merging episodes
    dplyr::group_by(
      .data$sending_location,
      .data$social_care_id,
      .data$record_keydate1,
      .data$smrtype,
      .data$pkg_count
    ) %>%
    # merge episodes with packages across quarters
    # drop variables not needed
    dplyr::summarise(
      sending_location = dplyr::last(.data$sending_location),
      social_care_id = dplyr::last(.data$social_care_id),
      sc_latest_submission = dplyr::last(.data$period),
      record_keydate1 = dplyr::last(.data$record_keydate1),
      record_keydate2 = dplyr::last(.data$record_keydate2),
      smrtype = dplyr::last(.data$smrtype),
      pkg_count = dplyr::last(.data$pkg_count),
      chi = dplyr::last(.data$chi),
      gender = dplyr::last(.data$gender),
      dob = dplyr::last(.data$dob),
      postcode = dplyr::last(.data$postcode),
      recid = dplyr::last(.data$recid),
      person_id = dplyr::last(.data$person_id),
      sc_send_lca = dplyr::last(.data$sc_send_lca)
    ) %>%
    # sort after merging
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$record_keydate1,
      .data$smrtype,
      .data$sc_latest_submission
    ) %>%
    # change the data format from data.table to data.frame
    tibble::as_tibble()

  if (write_to_disk) {
    write_file(
      qtr_merge,
      get_sc_at_episodes_path(check_mode = "write")
    )
  }

  return(qtr_merge)
}
