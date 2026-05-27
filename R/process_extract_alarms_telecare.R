#' Process the (year specific) Alarms Telecare extract
#'
#' @description This will read and process the
#' (year specific) Alarms Telecare extract, it will return the final data
#' and (optionally) write it to disk when it is 'TRUE'.
#'
#' @inheritParams process_extract_care_home
#'
#' @param BYOC_MODE BYOC_MODE
#' @param run_id run_id for BYOC
#' @param run_date_time run_date_time for BYOC
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_alarms_telecare <- function(data,
                                            year,
                                            write_to_disk = TRUE,
                                            BYOC_MODE = FALSE,
                                            run_id = NULL,
                                            run_date_time = NULL) {
  log_slf_event(stage = "process", status = "start", type = "at", year = year)

  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Check that we have data for this year
  if (!check_year_valid(year, "at")) {
    # If not return an empty tibble
    return(tibble::tibble())
  }

  # Now select episodes for given FY
  at_data <- data %>%
    dplyr::filter(is_date_in_fyyear(
      year,
      .data[["record_keydate1"]],
      .data[["record_keydate2"]]
    )) %>%
    dplyr::mutate(
      year = year,
      run_id = run_id,
      run_date_time = run_date_time
    ) %>%
    dplyr::select(
      "run_id",
      "run_date_time",
      "year",
      "recid",
      "smrtype",
      "anon_chi",
      "social_care_id",
      "person_id",
      "linking_id",
      "dob",
      "gender",
      "postcode",
      "sc_send_lca",
      "record_keydate1",
      "record_keydate2",
      "sc_latest_submission"
    )

  if (write_to_disk) {
    at_data %>%
      write_file(
        get_source_extract_path(year, type = "at", check_mode = "write", BYOC_MODE = BYOC_MODE),
        group_id = 3356, # sourcedev owner
        BYOC_MODE = BYOC_MODE,
        run_id = run_id,
        run_date_time = run_date_time
      )
  }

  log_slf_event(stage = "process", status = "complete", type = "at", year = year)

  return(at_data)
}
