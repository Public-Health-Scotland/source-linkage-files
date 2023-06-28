#' Process the CHI deaths extract
#'
#' @description This will process the CHI deaths extract, it will return the
#' final data and write the data out.
#'
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_it_chi_deaths <- function(data, write_to_disk = TRUE) {
  it_chi_deaths_clean <- data %>%
    dplyr::arrange(
      dplyr::desc(.data$death_date_nrs),
      dplyr::desc(.data$death_date_chi)
    ) %>%
    dplyr::distinct(.data$chi, .keep_all = TRUE) %>%
    # Use the NRS death_date unless it isn't there
    dplyr::mutate(
      death_date = dplyr::coalesce(.data$death_date_nrs, .data$death_date_chi)
    )

  if (write_to_disk) {
    it_chi_deaths_clean %>%
      write_file(get_slf_chi_deaths_path(check_mode = "write"))
  }

  return(it_chi_deaths_clean)
}
