#' Process the (year specific) Home Care extract
#'
#' @description This will read and process the
#' (year specific) Home Care extract, it will return the final data
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
process_extract_home_care <- function(data = NULL, year, client_lookup = NULL, write_to_disk = TRUE) {
  # Include is.null for passing the processed ALL Home care data through a list
  if (is.null(data)) {
    data <- readr::read_rds(get_sc_hc_episodes_path())
  }

  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Read client lookup
  if (is.null(client_lookup)) {
    client_lookup <- readr::read_rds(get_source_extract_path(year, type = "Client"))
  }

  # Selections for financial year------------------------------------

  hc_data <- data %>%
    # select episodes for FY
    dplyr::filter(is_date_in_fyyear(year, .data$record_keydate1, .data$record_keydate2)) %>%
    # remove any episodes where the latest submission was before the current year
    dplyr::filter(substr(.data$sc_latest_submission, 1, 4) >= convert_fyyear_to_year(year)) %>%
    # Match to client data
    dplyr::left_join(client_lookup, by = c("sending_location", "social_care_id")) %>%
    dplyr::mutate(year = year)

  # Home Care Hours ---------------------------------------

  hc_hours <- hc_data %>%
    # rename hours variables
    dplyr::rename(
      hc_hours_q1 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q1"),
      hc_hours_q2 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q2"),
      hc_hours_q3 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q3"),
      hc_hours_q4 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q4")
    ) %>%
    # remove hours variables not from current year
    dplyr::select(-(tidyselect::contains("hc_hours_2"))) %>%
    # create annual hours variable
    dplyr::mutate(hc_hours_annual = rowSums(dplyr::across(tidyselect::contains("hc_hours_q"))))


  # Home Care Costs ---------------------------------------

  hc_costs <- hc_hours %>%
    # rename costs variables
    dplyr::rename(
      hc_costs_q1 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q1"),
      hc_costs_q2 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q2"),
      hc_costs_q3 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q3"),
      hc_costs_q4 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q4")
    ) %>%
    # remove cost variables not from current year
    dplyr::select(-(tidyselect::contains("hc_cost_2"))) %>%
    # create cost total net
    dplyr::mutate(cost_total_net = rowSums(dplyr::across(tidyselect::contains("hc_costs_q"))))


  # Outfile ---------------------------------------

  outfile <- hc_costs %>%
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
      tidyselect::starts_with("hc_hours"),
      tidyselect::starts_with("hc_cost"),
      "cost_total_net",
      "hc_provider",
      "hc_reablement",
      "person_id",
      tidyselect::starts_with("sc_")
    )

  if (write_to_disk) {
    # Save .rds file
    outfile %>%
      write_rds(get_source_extract_path(year, type = "HC", check_mode = "write"))
  }

  return(outfile)
}