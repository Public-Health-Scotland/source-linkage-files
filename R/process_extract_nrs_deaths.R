#' Process the NRS Deaths extract
#'
#' @description This will read and process the
#' nrs deaths extract, it will return the final data
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
process_extract_nrs_deaths <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning  ---------------------------------------

  deaths_clean <- data %>%
    dplyr::mutate(record_keydate2 = .data$record_keydate1) %>%
    # create recid and year variables
    dplyr::mutate(
      recid = "NRS",
      year = year
    ) %>%
    # fix dummy gpprac codes
    dplyr::mutate(gpprac = convert_eng_gpprac_to_dummy(.data$gpprac)) %>%
    dplyr::mutate(smrtype = add_smr_type(.data$recid))

  if (write_to_disk) {
    # Save as rds file
    deaths_clean %>%
      write_rds(get_source_extract_path(year, "Deaths", check_mode = "write"))
  }

  return(deaths_clean)
}
