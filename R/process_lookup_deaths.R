#' Create the SLF Deaths lookup
#'
#' @description Currently this just uses the NRS death dates 'as is', with no
#' corrections or modifications, it is expected that this will be expanded to
#' use the CHI deaths extract from IT as well as taking into account data in
#' the episode file to assess the validity of a death date.
#'
#' @param year The year to process, in FY format.
#' @param nrs_deaths_data_path Path to NRS deaths data.
#' @param chi_deaths_data_path Path to IT CHI deaths data.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return a [tibble][tibble::tibble-package] containing the episode file
#' @export
process_slf_deaths_lookup <- function(
    year,
    nrs_deaths_data_path = get_source_extract_path(year, "Deaths"),
    chi_deaths_data_path = get_slf_chi_deaths_path(),
    write_to_disk = TRUE) {
  nrs_deaths_data <- read_file(nrs_deaths_data_path,
    col_select = c("chi", "record_keydate1")
  )

  slf_deaths_lookup <- nrs_deaths_data %>%
    dplyr::mutate(
      death_date = .data$record_keydate1,
      deceased = TRUE,
      .keep = "none"
    )

  if (write_to_disk) {
    write_file(
      slf_deaths_lookup,
      get_slf_deaths_lookup_path(year, check_mode = "write")
    )
  }

  return(slf_deaths_lookup)
}
