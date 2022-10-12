#' Process LTC IT extract
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#'
process_lookup_ltc <- function(data, year, write_to_disk = TRUE) {

  # Create LTC flags 1/0------------------------------------

  # Set flags to 1 or 0 based on FY
  # then sort by chi

  ltc_flags <- data %>%
    dplyr::mutate(dplyr::across(
      tidyselect::ends_with("date"),
      list(flag = ~ dplyr::if_else(is.na(.x) | .x > end_fy(year), 0L, 1L))
    )) %>%
    dplyr::rename_with(
      .cols = tidyselect::ends_with("flag"),
      .fn = ~ stringr::str_remove(.x, "_date_flag")
    )

  # Save Outfile---------------------------------------------

  if (write_to_disk) {
    # Save .rds file
    ltc_flags %>%
      dplyr::arrange(.data$chi) %>%
      write_rds(get_ltcs_path(year, check_mode = "write"))
  }

  return(ltc_flags)
}
