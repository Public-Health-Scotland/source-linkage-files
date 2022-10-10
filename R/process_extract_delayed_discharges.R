#' Process the delayed discharges extract
#'
#' @description This will read and process the
#' delayed discharges extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param year The year to process, in FY format.
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts

process_extract_delayed_discharges <- function(data, year, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning---------------------------------------

  # Specify MH specialties for dealing with correct DD dates
  mh_spec <- c("CC", "G1", "G2", "G21", "G22", "G3", "G4", "G5", "G6", "G61", "G62", "G63")

  dd_clean <- data %>%
    # Use end of the month date for records with no end date (but we think have ended)
    # Create a flag for these records
    dplyr::mutate(
      month_end = lubridate::ceiling_date(.data$keydate1_dateformat, "month") - 1,
      amended_dates = dplyr::case_when(
        .data$keydate2_dateformat == as.Date("1900-01-01") ~ TRUE,
        TRUE ~ FALSE
      ),
      keydate2_dateformat = dplyr::if_else(.data$ammended_dates, .data$month_end, .data$keydate2_dateformat)
    ) %>%
    # Drop any records with obviously bad dates
    dplyr::filter(
      (.data$keydate1_dateformat <= .data$keydate2_dateformat) | is.na(.data$keydate2_dateformat)
    ) %>%
    # set up variables
    dplyr::mutate(
      recid = "DD",
      year = year
    ) %>%
    # recode blanks to NA
    dplyr::mutate(
      dplyr::across(tidyselect::ends_with("delay_reason"), dplyr::na_if, "")
    ) %>%
    # create flags for no_end_date and correct_dates
    dplyr::mutate(
      # Flag records with correct date
      dates_in_fyyear = is_date_in_fyyear(year, .data$keydate1_dateformat, .data$keydate2_dateformat),
      # Flag records with no end date
      not_mh_spec = is.na(.data$keydate2_dateformat) & !(.data$spec %in% mh_spec)
    ) %>%
    # Keep only records which have an end date (except Mental Health) and fall within our dates.
    dplyr::filter(.data$dates_in_fyyear, !.data$not_mh_spec)


  ## save outfile ---------------------------------------
  outfile <- dd_clean %>%
    dplyr::select(
      .data$year,
      .data$recid,
      .data$original_admission_date,
      .data$keydate1_dateformat,
      .data$keydate2_dateformat,
      .data$chi,
      .data$postcode,
      .data$delay_end_reason,
      .data$primary_delay_reason,
      .data$secondary_delay_reason,
      .data$spec,
      .data$location,
      .data$hbtreatcode,
      .data$dd_responsible_lca,
      .data$monthflag,
      .data$cennum
    )

  outfile %>%
    # Save as rds file
    write_rds(get_source_extract_path(year, "DD", check_mode = "write"))
}
