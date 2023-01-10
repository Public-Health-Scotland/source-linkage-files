#' Process th GP OOH Consultations extract
#'
#' @description This will read and process the
#' GP OOH Consultations extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_ooh_consultations <- function(data, year) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Consultations Data ---------------------------------
  ## Data Cleaning

  fnc_consulation_types <- c(
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

  consultations_filtered <- consultations_file %>%
    dtplyr::lazy_dt() %>%
    # Filter missing / bad CHI numbers
    dplyr::filter(phsmethods::chi_check(chi) == "Valid CHI") %>%
    # Fix some times - if end before start, remove the time portion
    dplyr::mutate(
      bad_dates = record_keydate1 > record_keydate2,
      record_keydate1 = dplyr::if_else(bad_dates,
        lubridate::floor_date(record_keydate1, "day"),
        record_keydate1
      ),
      record_keydate2 = dplyr::if_else(bad_dates,
        lubridate::floor_date(record_keydate1, "day"),
        record_keydate2
      )
    ) %>%
    # Some episodes are wrongly included in the BOXI extract
    # Filter to episodes with any time in the given financial year.
    dplyr::filter(is_date_in_fyyear(year, record_keydate1, record_keydate2)) %>%
    # Filter out Flow navigation center data
    dplyr::filter(!(consultation_type_unmapped %in% fnc_consulation_types)) %>%
    dplyr::as_tibble()

  rm(consultations_file, fnc_consulation_types)

  consultations_covid <- consultations_filtered %>%
    dplyr::mutate(consultation_type = dplyr::if_else(is.na(consultation_type),
      dplyr::case_when(
        consultation_type_unmapped == "COVID19 ASSESSMENT" ~ consultation_type_unmapped,
        consultation_type_unmapped == "COVID19 ADVICE" ~ consultation_type_unmapped,
        consultation_type_unmapped %in% c(
          "COVID19 HOME VISIT",
          "COVID19 OBSERVATION",
          "COVID19 VIDEO CALL",
          "COVID19 TEST"
        ) ~ "COVID19 OTHER"
      ),
      consultation_type
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

  rm(consultations_filtered, consultations_covid)

  return(consultations_clean)
}
