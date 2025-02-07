#' Create the SLF Deaths lookup
#'
#' @description Use all-year refined death data to produce year-specific
#' slf_deaths_lookup with deceased flag added.
#'
#' @param year The year to process, in FY format.
#' @param refined_death refined death date combining nrs and it_chi.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return a [tibble][tibble::tibble-package] add deceased flag to deaths
#' @export
process_slf_deaths_lookup <- function(
    year,
    refined_death = read_file(get_combined_slf_deaths_lookup_path()),
    write_to_disk = TRUE) {
  # create slf deaths lookup
  slf_deaths_lookup <- refined_death %>%
    # Filter the chi death dates to the FY as the lookup is by FY
    dplyr::filter(fy == year) %>%
    # use the BOXI NRS death date by default, but if it's missing, use the chi death date.
    dplyr::mutate(
      deceased = TRUE
    )

  if (write_to_disk) {
    write_file(
      slf_deaths_lookup,
      get_slf_deaths_lookup_path(year, check_mode = "write")
    )
  }

  return(slf_deaths_lookup)
}
