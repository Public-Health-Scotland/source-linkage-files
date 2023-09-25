#' Process the (year specific) SDS extract
#'
#' @description This will read and process the
#' (year specific) SDS extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_extract_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_sds <- function(
    data,
    year,
    client_lookup,
    write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Check that we have data for this year
  if (!check_year_valid(year, "SDS")) {
    # If not return an empty tibble
    return(tibble::tibble())
  }

  outfile <- data %>%
    # Select episodes for given FY
    dplyr::filter(is_date_in_fyyear(
      year,
      .data[["record_keydate1"]],
      .data[["record_keydate2"]]
    )) %>%
    dplyr::left_join(client_lookup, by = c("sending_location", "social_care_id")) %>%
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
      write_file(get_source_extract_path(year, type = "SDS", check_mode = "write"))
  }

  return(outfile)
}
