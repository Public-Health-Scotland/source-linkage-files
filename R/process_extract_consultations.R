#' Process the GP OOH Consultations extract
#'
#' @description This will read and process the
#' GP OOH Consultations extract, it will return the final data
#' but also write this out as an rds.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
process_extract_ooh_consultations <- function(data, year) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Consultations Data ---------------------------------
  ## Data Cleaning

  fnc_consultation_types <- c(
    "ED APPOINTMENT",
    "ED TELEPHONE ASSESSMENT",
    "ED TO BOOK",
    "ED TELEPHONE / REMOTE CONSULTATION",
    "MIU APPOINTMENT",
    "MIU TELEPHONE ASSESSMENT",
    "MIU TO BOOK",
    "MIU TELEPHONE / REMOTE CONSULTATION",
    "TELEPHONE ASSESSMENT",
    "TELEPHONE/VIRTUAL ASSESSMENT"
  )

  consultations_filtered <- data %>%
    data.table::as.data.table() %>%
    # Filter missing / bad CHI numbers
    dplyr::filter(phsmethods::chi_check(.data$chi) == "Valid CHI") %>%
    dplyr::mutate(
      attendance_status = dplyr::case_match(
        .data$attendance_status,
        "Y" ~ 1L,
        "N" ~ 8L
      )
    ) %>%
    # Fix some times - if end before start, remove the time portion
    dplyr::mutate(
      bad_dates = .data$record_keydate1 > .data$record_keydate2,
      record_keydate1 = dplyr::if_else(.data$bad_dates,
        lubridate::floor_date(.data$record_keydate1, "day"),
        .data$record_keydate1
      ),
      record_keydate2 = dplyr::if_else(.data$bad_dates,
        lubridate::floor_date(.data$record_keydate1, "day"),
        .data$record_keydate2
      )
    ) %>%
    # Some episodes are wrongly included in the BOXI extract
    # Filter to episodes with any time in the given financial year.
    dplyr::filter(is_date_in_fyyear(year, .data$record_keydate1, .data$record_keydate2)) %>%
    # Filter out Flow navigation center data
    dplyr::filter(!(.data$consultation_type_unmapped %in% fnc_consultation_types)) %>%
    dplyr::as_tibble()


  consultations_covid <- consultations_filtered %>%
    dplyr::mutate(consultation_type = dplyr::if_else(is.na(.data$consultation_type),
      dplyr::case_when(
        .data$consultation_type_unmapped == "COVID19 ASSESSMENT" ~ .data$consultation_type_unmapped,
        .data$consultation_type_unmapped == "COVID19 ADVICE" ~ .data$consultation_type_unmapped,
        .data$consultation_type_unmapped %in% c(
          "COVID19 HOME VISIT",
          "COVID19 OBSERVATION",
          "COVID19 VIDEO CALL",
          "COVID19 TEST"
        ) ~ "COVID19 OTHER"
      ),
      .data$consultation_type
    ))

  # Clean up some overlapping episodes
  # Only merge if they look like duplicates other than the time,
  # In which case take the earliest start and latest end.
  consultations_clean <- consultations_covid

  # TODO Remove / merge overlapping records in GP OoHs
  # dtplyr::lazy_dt() %>%
  # # Sort in reverse order so we can use coalesce which takes the first non-missing value
  # dplyr::arrange(chi, ooh_case_id, dplyr::desc(record_keydate1), dplyr::desc(record_keydate2)) %>%
  # # This seems to be enough to identify a unique episode
  # dplyr::group_by(chi, ooh_case_id, consultation_type, location) %>%
  # # Records will be merged if they don't look unique and there is overlap or no time between them
  # dplyr::mutate(episode_counter = replace_na(record_keydate1 > lag(record_keydate2), TRUE) %>%
  #   cumsum()) %>%
  # dplyr::group_by(chi, ooh_case_id, consultation_type, location, episode_counter) %>%
  # dplyr::summarise(
  #   record_keydate1 = min(record_keydate1),
  #   record_keydate2 = max(record_keydate2),
  #   dplyr::across(c(dplyr::everything(), -"record_keydate1", -"record_keydate2"), dplyr::coalesce)
  # ) %>%
  # dplyr::ungroup() %>%
  # dplyr::as_tibble()

  return(consultations_clean)
}
