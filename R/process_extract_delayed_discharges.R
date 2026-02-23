#' Process the delayed discharges extract
#'
#' @description This will read and process the
#' delayed discharges extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_delayed_discharges <- function(
  data,
  year,
  write_to_disk = TRUE
) {
  log_slf_event(stage = "process", status = "start", type = "dd", year = year)

  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Specify years available for running
  if (year < "1617") {
    return(NULL)
  }

  # Specify MH specialties for dealing with correct DD dates
  mh_spec <- c(
    "CC",
    "G1",
    "G2",
    "G21",
    "G22",
    "G3",
    "G4",
    "G5",
    "G6",
    "G61",
    "G62",
    "G63"
  )

  dd_clean <- data %>%
    dplyr::rename(
      record_keydate1 = .data[["rdd"]],
      record_keydate2 = .data[["delay_end_date"]]
    ) %>%
    # Use end of the month date for records with no end date
    # (but we think have ended)
    # Create a flag for these records
    dplyr::mutate(
      month_end = lubridate::ceiling_date(.data[["monthflag"]], "month") - 1L,
      amended_dates = .data[["record_keydate2"]] == as.Date("1900-01-01"),
      record_keydate2 = dplyr::if_else(
        .data$record_keydate2 == as.Date("1900-01-01"),
        .data$month_end,
        .data$record_keydate2
      )
    ) %>%
    # Drop any records with obviously bad dates
    dplyr::filter(
      (.data$record_keydate1 <= .data$record_keydate2) | is.na(.data$record_keydate2)
    ) %>%
    # set up variables
    dplyr::mutate(
      recid = "DD",
      year = year
    ) %>%
    # recode blanks to NA
    dplyr::mutate(
      dplyr::across(tidyselect::ends_with("_delay_reason"), dplyr::na_if, "")
    ) %>%
    # create flags for no_end_date and correct_dates
    dplyr::mutate(
      # Flag records with correct date
      dates_in_fyyear = is_date_in_fyyear(
        year,
        .data$record_keydate1,
        .data$record_keydate2
      ),
      # Flag records with no end date
      not_mh_spec = is.na(.data$record_keydate2) & !(.data$spec %in% mh_spec)
    ) %>%
    # Keep only records which have an end date (except Mental Health) and fall
    # within our dates.
    dplyr::filter(.data$dates_in_fyyear, !.data$not_mh_spec)

  dd_final <- dd_clean %>%
    dplyr::select(
      "year",
      "recid",
      "anon_chi",
      "postcode",
      "dd_responsible_lca",
      "original_admission_date",
      "record_keydate1",
      "record_keydate2",
      "amended_dates",
      "delay_end_reason",
      "primary_delay_reason",
      "secondary_delay_reason",
      "hbtreatcode",
      "location",
      "spec"
    )

  if (write_to_disk) {
    write_file(
      dd_final,
      get_source_extract_path(year, "dd", check_mode = "write"),
      group_id = 3356 # sourcedev owner
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "dd", year = year)

  return(dd_final)
}
