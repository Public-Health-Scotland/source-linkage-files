#' Process the Nation Records of Scotland (NRS) Deaths extract
#'
#' @description This will process the NRS deaths extract, it will return the
#' final data and write this out.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' @param BYOC_MODE BYOC_MODE
#' @param run_id run_id for BYOC
#' @param run_date_time run_date_time for BYOC
#' `TRUE` i.e. write the data to disk.
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
  log_slf_event(
    stage = "process",
    status = "start",
    type = "deaths",
    year = year
  )

  stopifnot(length(year) == 1L)

  year <- check_year_format(year)

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
      run_date_time = run_date_time
    )

  if (write_to_disk) {
    deaths_clean %>%
      write_file(
        get_source_extract_path(
          year,
          "deaths",
          check_mode = "write",
          BYOC_MODE = BYOC_MODE
        ),
        BYOC_MODE = BYOC_MODE,
        group_id = 3356 # sourcedev owner
      )
  }

  log_slf_event(
    stage = "process",
    status = "complete",
    type = "deaths",
    year = year
  )

  return(deaths_clean)
}
