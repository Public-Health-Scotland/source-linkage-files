#' Process the (year specific) SDS extract
#'
#' @description This will read and process the
#' (year specific) SDS extract, it will return the final data
#' but also write this out as rds.
#'
#' @param data The extract to process. (Optional) Can be passed through a data list or
#' alternatively read the file from disk.
#' @param year The year to process, in FY format.
#' @param client_lookup The client lookup extract (Optional) Can be passed through a data list
#' or alternatively read the file from disk.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_sds <- function(data = NULL, year, client_lookup = NULL, write_to_disk = TRUE) {
  # Include is.null for passing the processed ALL SDS data through a list
  if (is.null(data)) {
    data <- readr::read_rds(get_sc_sds_episodes_path())
  }

  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Read client lookup
  if (is.null(client_lookup)) {
    client_table <- readr::read_rds(get_source_extract_path(year, type = "Client"))
  }

  # Now select epsiodes for given FY

  outfile <- data %>%
    dplyr::filter(is_date_in_fyyear(convert_year_to_fyyear(substr(.data$sc_latest_submission, 1, 4)), .data$record_keydate1, .data$record_keydate2)) %>%
    dplyr::left_join(client_table, by = c("sending_location", "social_care_id")) %>%
    dplyr::mutate(
      year = year
    ) %>%
    dplyr::select(
      "recid",
      "smrtype",
      "chi",
      "dob",
      "gender",
      "postcode",
      "record_keydate1",
      "record_keydate2",
      "sc_send_lca",
      "sc_living_alone",
      "sc_support_from_unpaid_carer",
      "sc_social_worker",
      "sc_type_of_housing",
      "sc_meals",
      "sc_day_care"
    )

  if (write_to_disk) {
    outfile %>%
      write_rds(get_source_extract_path(year, type = "SDS", check_mode = "write"))
  }

  return(outfile)
}
