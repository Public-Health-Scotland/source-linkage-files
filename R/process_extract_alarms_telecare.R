#' Process the (year specific) Alarms Telecare extract
#'
#' @description This will read and process the
#' (year specific) Alarms Telecare extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_extract_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_alarms_telecare <- function(
    data,
    year,
    write_to_disk = TRUE) {
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
      year = year
    ) %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
      "anon_chi",
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
        get_source_extract_path(year, type = "at", check_mode = "write")
      )
  }

  return(at_data)
}
