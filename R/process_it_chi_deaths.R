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
process_it_chi_deaths <- function(data,
                                  write_to_disk = TRUE,
                                  BYOC_MODE = FALSE,
                                  run_id = NA,
                                  run_date_time = NA
                                  ) {

  log_slf_event(stage = "process", status = "start", type = "it_chi_deaths", year = "all")

  it_chi_deaths_clean <- data %>%
    dplyr::arrange(
      dplyr::desc(.data$death_date_nrs),
      dplyr::desc(.data$death_date_chi)
    ) %>%
    dplyr::distinct(.data$anon_chi, .keep_all = TRUE) %>%
    # remove death_date_nrs as this is the nrs weekly unvalidated data and we should not use this.
    # the boxi nrs death date is more reliable as this is provided monthly and is validated.
    dplyr::mutate(
      death_date_chi = lubridate::ymd(.data$death_date_chi),
      run_id = run_id,
      run_date_time = run_date_time
    ) %>%
    dplyr::select(
      "run_id",
      "run_date_time",
      "anon_chi",
      "death_date_chi"
      )

  if (write_to_disk) {
    write_file(
      it_chi_deaths_clean,
      get_slf_chi_deaths_path(
        BYOC_MODE,
        check_mode = "write"
      ),
      BYOC_MODE = BYOC_MODE,
      group_id = 3206 # hscdiip owner
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "it_chi_deaths", year = "all")

  return(it_chi_deaths_clean)
}
