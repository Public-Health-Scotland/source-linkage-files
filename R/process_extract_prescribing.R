#' Process the prescribing extract
#'
#' @description This will read and process the
#' prescribing extract, it will return the final data
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
process_extract_prescribing <- function(data, year, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning--------------------------------------------
  pis_clean <- data %>%
    # filter for chi NA
    dplyr::filter(phsmethods::chi_check(.data$chi) == "Valid CHI") %>%
    # change back to anon_chi
    slfhelper::get_anon_chi() %>%
    # create variables recid and year
    dplyr::mutate(
      recid = "PIS",
      year = year,
      # Recode GP Practice into a 5 digit number
      # assume that if it starts with a letter it's an English practice
      # and so recode to 99995
      gpprac = convert_eng_gpprac_to_dummy(.data$gpprac)
    ) %>%
    # Set date to the end of the FY
    dplyr::mutate(
      record_keydate1 = end_fy(year),
      record_keydate2 = .data$record_keydate1,
      # Add SMR type variable
      smrtype = add_smrtype(.data$recid)
    )

  # Issue a warning if rows were removed
  if (nrow(pis_clean) != nrow(data)) {
    cli::cli_warn(message = c(
      "{nrow(data) - nrow(pis_clean)} row{?s} were removed from the PIS
    extract because the CHI number was invalid",
      "Check the raw PIS extract: {.path {get_it_prescribing_path(year)}}"
    ))
  }

  if (write_to_disk) {
    write_file(
      pis_clean,
      get_source_extract_path(year, "pis", check_mode = "write")
    )
  }

  return(pis_clean)
}
