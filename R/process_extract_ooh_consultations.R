#' Process the GP OOH Consultations extract
#'
#' @description This will read and process the
#' GP OOH Consultations extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
process_extract_ooh_consultations <- function(data, year) {
  # to skip warning no visible binding for global variable when using data.table
  distinct_check <- consultation_type <- location <-
    record_keydate1 <- record_keydate2 <- anon_chi <-
    ooh_case_id <- episode_counter <- NULL


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
    # change to chi for phs methods
    slfhelper::get_chi() %>%
    # Filter missing / bad CHI numbers
    dplyr::filter(phsmethods::chi_check(.data$chi) == "Valid CHI") %>%
    # change back to anon_chi
    slfhelper::get_anon_chi() %>%
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
  consultations_clean <- consultations_covid %>%
    # Sort in reverse order so we can use coalesce which takes the first non-missing value
    dplyr::arrange(
      .data$anon_chi,
      .data$ooh_case_id,
      .data$record_keydate1,
      .data$record_keydate2
    ) %>%
    data.table::as.data.table()

  consultations_clean[, distinct_check := (
    record_keydate1 > data.table::shift(record_keydate2, fill = NA, type = "lag")
  ),
  by = list(anon_chi, ooh_case_id, consultation_type, location)
  ]
  consultations_clean[, distinct_check := tidyr::replace_na(distinct_check, TRUE)]
  consultations_clean[, episode_counter := cumsum(distinct_check),
    by = list(anon_chi, ooh_case_id, consultation_type, location)
  ]
  consultations_clean[,
    c(
      "record_keydate1",
      "record_keydate2"
    ) := list(
      min(record_keydate1),
      max(record_keydate2)
    ),
    by = list(
      anon_chi,
      ooh_case_id,
      consultation_type,
      location,
      episode_counter
    )
  ]

  # replace NA with previous non-NA value in each column
  col_sel <- names(consultations_clean)
  col_sel <- col_sel[!(col_sel %in% c("record_keydate1", "record_keydate2"))]
  consultations_clean[,
    (col_sel) := lapply(.SD, zoo::na.locf, na.rm = FALSE),
    .SDcols = col_sel
  ]

  consultations_clean[
    ,
    c(
      "distinct_check",
      "episode_counter"
    ) := list(NULL, NULL)
  ]
  consultations_clean <- unique(consultations_clean) %>%
    dplyr::as_tibble()
  # cleaning up overlapping episodes done

  return(consultations_clean)
}
