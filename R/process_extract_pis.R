#' Process the PIS extract
#'
#' @description This will read and process the
#' PIS extract, it will return the final data
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
process_extract_pis <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning--------------------------------------------------

  pis_clean <- data %>%
    # filter for chi NA
    dplyr::filter(phsmethods::chi_check(.data$chi) == "Valid CHI") %>%
    # create variables recid and year
    dplyr::mutate(
      recid = "PIS",
      year = year
    ) %>%
    # Recode GP Practice into a 5 digit number
    # assume that if it starts with a letter it's an English practice
    # and so recode to 99995
    mutate(gpprac = convert_eng_gpprac_to_dummy(gpprac)) %>%
    # Set date to the end of the FY
    dplyr::mutate(
      record_keydate1 = end_fy(.data$year),
      record_keydate2 = .data$record_keydate1,
      # Add SMR type variable
      smrtype = add_smr_type(.data$recid)
    )

  # Issue a warning if rows were removed
  if (nrow(pis_clean) != nrow(data)) {
    cli::cli_warn(message = c(
      "{nrow(data) - nrow(pis_clean)} row{?s} were removed from the PIS
    extract because the CHI number was invalid",
      "Check the raw PIS extract: {.path {get_it_prescribing_path(year)}}"
    ))
  }


  # Save out ---------------------------------------

  if (write_to_disk) {
    # Save as rds file
    pis_clean %>%
      write_rds(get_source_extract_path(year, "PIS", check_mode = "write"))
  }

  return(pis_clean)
}
