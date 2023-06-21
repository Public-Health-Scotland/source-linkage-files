#' Create the SLF Deaths lookup
#'
#' @description Currently this just uses the NRS death dates 'as is', with no
#' corrections or modifications, it is expected that this will be expanded to
#' use the CHI deaths extract from IT as well as taking into account data in
#' the episode file to assess the validity of a death date.
#'
#' @param year
#' @param nrs_deaths_data_path
#' @param chi_deaths_data_path
#' @param write_to_disk
#'
#' @return
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
