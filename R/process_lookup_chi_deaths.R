#' Process the CHI deaths lookup
#'
#' @description This will read and process the
#' CHI deaths lookup, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts

process_lookup_chi_deaths <- function(data, write_to_disk = TRUE) {

  # Data Cleaning------------------------------------------------------

  # One record per chi
  deaths_clean <- data %>%
    dplyr::arrange(dplyr::desc(.data$death_date_nrs), dplyr::desc(.data$death_date_chi)) %>%
    dplyr::distinct(.data$chi, .keep_all = TRUE) %>%
    # Use the NRS deathdate unless it isn't there
    dplyr::mutate(death_date = dplyr::coalesce(.data$death_date_nrs, .data$death_date_chi))


  # Save File--------------------------------------------------------

  if (write_to_disk) {
    # Save .rds file
    deaths_clean %>%
      write_rds(get_slf_deaths_path(check_mode = "write"))
  }

  return(deaths_clean)
}
