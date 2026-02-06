#' Process the Nation Records of Scotland (NRS) Deaths extract
#'
#' @description This will process the NRS deaths extract, it will return the
#' final data and write this out.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_nrs_deaths <- function(data, year, write_to_disk = TRUE) {
  log_slf_event(stage = "process", status = "start", type = "deaths", year = year)

  stopifnot(length(year) == 1L)

  year <- check_year_format(year)

  deaths_clean <- data %>%
    dplyr::mutate(
      record_keydate2 = .data$record_keydate1,
      recid = "NRS",
      year = year,
      gpprac = convert_eng_gpprac_to_dummy(.data$gpprac),
      smrtype = add_smrtype(.data$recid)
    )

  if (write_to_disk) {
    deaths_clean %>%
      write_file(get_source_extract_path(year, "deaths", check_mode = "write"),
        group_id = 3356 # sourcedev owner
      )
  }

  log_slf_event(stage = "process", status = "complete", type = "deaths", year = year)

  return(deaths_clean)
}
