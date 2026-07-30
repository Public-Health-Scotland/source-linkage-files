#' Process the Nation Records of Scotland (NRS) Deaths extract
#'
#' @description This will process the NRS deaths extract, it will return the
#' final data and write this out.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id run_id for BYOC
#' @param run_date_time run_date_time for BYOC
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_nrs_deaths <- function(data,
                                       year,
                                       write_to_disk = TRUE,
                                       BYOC_MODE = FALSE,
                                       run_id = NA,
                                       run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "nrs_deaths", year = year)

  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year, format = "fyyear")

  # If no data is available in the FY then return immediately.
  if (identical(data, tibble::tibble())) {
    return(data)
  }

  # Data Cleaning  ---------------------------------------

  deaths_clean <- data %>%
    dplyr::mutate(
      record_keydate2 = .data$record_keydate1,
      recid = "NRS",
      year = year,
      gpprac = convert_eng_gpprac_to_dummy(.data$gpprac),
      smrtype = add_smrtype(.data$recid)
    ) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time,
      dob = lubridate::as_date(dob),
      record_keydate1 = lubridate::as_date(record_keydate1),
      record_keydate2 = lubridate::as_date(record_keydate2)
    )

  if (write_to_disk) {
    write_file(
      data = deaths_clean,
      path = get_source_extract_path(
        year = year,
        type = "nrs_deaths",
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      group_id = 3356, # sourcedev owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "nrs_deaths", year = year)

  return(deaths_clean)
}
