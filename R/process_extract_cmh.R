#' Process the Community Mental Health (CMH) extract
#'
#' @description This will read and process the
#' CMH extract, it will return the final data
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
process_extract_cmh <- function(data,
                                year,
                                write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # If data is available in the FY then run processing.
  if (identical(data, tibble::tibble())) {
    return(data)
  }

  # Data Cleaning  ---------------------------------------

  cmh_clean <- data %>%
    # create recid, year, SMRType variables
    dplyr::mutate(
      recid = "CMH",
      smrtype = add_smrtype(recid = .data$recid),
      year = year
    ) %>%
    # contact end time
    dplyr::mutate(keytime2 = hms::as.hms(
      .data$keytime1 + lubridate::dminutes(.data$duration)
    )) %>%
    # record key date 2
    dplyr::mutate(record_keydate2 = .data$record_keydate1) %>%
    # create blank diag 6
    dplyr::mutate(diag6 = NA)

  cmh_processed <- cmh_clean %>%
    dplyr::select(
      "year",
      "recid",
      "record_keydate1",
      "record_keydate2",
      "keytime1",
      "keytime2",
      "smrtype",
      "anon_chi",
      "gender",
      "dob",
      "gpprac",
      "postcode",
      "hbrescode",
      "hscp",
      "location",
      "hbtreatcode",
      "diag1",
      "diag2",
      "diag3",
      "diag4",
      "diag5",
      "diag6"
    )

  if (write_to_disk) {
    write_file(
      cmh_processed,
      get_source_extract_path(year, "cmh", check_mode = "write"),
      group_id = 3356 # sourcedev owner
    )
  }

  return(cmh_processed)
}
