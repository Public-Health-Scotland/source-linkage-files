#' Create the SLF Deaths lookup
#'
#' @description Currently this just uses the NRS death dates 'as is', with no
#' corrections or modifications, it is expected that this will be expanded to
#' use the CHI deaths extract from IT as well as taking into account data in
#' the episode file to assess the validity of a death date.
#'
#' @param year The year to process, in FY format.
#' @param nrs_deaths_data NRS deaths data.
#' @param chi_deaths_data IT CHI deaths data.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return a [tibble][tibble::tibble-package] containing the episode file
#' @export
add_deceased_flag <- function(
    year,
    refined_death = read_file(get_combined_slf_deaths_lookup_path()) %>% slfhelper::get_chi(),
    write_to_disk = TRUE) {

  # create slf deaths lookup

    dplyr::mutate(
      death_date = dplyr::if_else(is.na(.data$record_keydate1),
        .data$death_date_chi, .data$record_keydate1
      ),
      deceased = TRUE,
      .keep = "unused"
    ) %>%
    # save anon chi on disk
    slfhelper::get_anon_chi()

  if (write_to_disk) {
    write_file(
      slf_deaths_lookup,
      get_slf_deaths_lookup_path(year, check_mode = "write")
    )
  }

  return(slf_deaths_lookup)
}
