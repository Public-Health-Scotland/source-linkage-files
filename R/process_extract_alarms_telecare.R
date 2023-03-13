#' Process the (year specific) Alarms Telecare extract
#'
#' @description This will read and process the
#' (year specific) Alarms Telecare extract, it will return the final data
#' but also write this out as rds.
#'
#' @param file_path The extract to process - Read the file from disk.
#' @param year The year to process, in FY format.
#' @param client_lookup_path The client lookup extract - Read the file from disk.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_alarms_telecare <- function(file_path = get_sc_at_episodes_path(),
                                            year,
                                            client_lookup_path = get_source_extract_path(year, type = "Client"),
                                            write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Read client lookup
  client_table <- readr::read_rds(client_lookup_path)

  # Read data
  data <- readr::read_rds(file_path)

  # process extract------------------------------------------------------

  # Now select episodes for given FY
  outfile <- data %>%
    dplyr::filter(is_date_in_fyyear(
      year,
      .data$record_keydate1,
      .data$record_keydate2
    )) %>%
    dplyr::left_join(client_table, by = c("sending_location", "social_care_id")) %>%
    dplyr::mutate(
      year = year
    ) %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
      "chi",
      "dob",
      "gender",
      "postcode",
      "sc_send_lca",
      "record_keydate1",
      "record_keydate2",
      "person_id",
      "sc_latest_submission",
      "sc_living_alone",
      "sc_support_from_unpaid_carer",
      "sc_social_worker",
      "sc_type_of_housing",
      "sc_meals",
      "sc_day_care"
    )

  if (write_to_disk) {
    outfile %>%
      write_rds(get_source_extract_path(year, type = "AT", check_mode = "write"))
  }

  return(outfile)
}
