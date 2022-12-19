#' Process the (year specific) Care Home extract
#'
#' @description This will read and process the
#' (year specific) Care Home extract, it will return the final data
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
process_extract_care_home <- function(data = NULL, year, client_lookup = NULL, write_to_disk = TRUE) {
  # Include is.null for passing the processed ALL care home data through a list
  if (is.null(data)) {
    # TODO - use RDS version, ALL ch data still WIP
    data <- haven::read_sav(get_sc_ch_episodes_path(update = latest_update(), ext = "zsav"))
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

  ch_data <- data %>%
    # select episodes for FY
    dplyr::filter(is_date_in_fyyear(year, .data$record_keydate1, .data$record_keydate2)) %>%
    # remove any episodes where the latest submission was before the current year
    dplyr::filter(substr(.data$sc_latest_submission, 1, 4) >= convert_fyyear_to_year(year)) %>%
    # Match to client data
    dplyr::left_join(client_lookup, by = c("sending_location", "social_care_id"))


  # Data Cleaning ---------------------------------------
  source_ch_clean <- ch_data %>%
    # create variables
    dplyr::mutate(
      year = year,
      recid = "CH",
      smrtype = add_smr_type(recid = "CH")
    ) %>%
    # compute lca variable from sending_location
    dplyr::mutate(sc_send_lca = convert_sending_location_to_lca(.data$sending_location)) %>%
    # bed days
    create_monthly_beddays(year,
      admission_date = .data$record_keydate1,
      discharge_date = .data$record_keydate2
    ) %>%
    # year stay
    dplyr::mutate(
      yearstay = rowSums(dplyr::across(tidyselect::ends_with("_beddays"))),
      # total length of stay
      stay = calculate_stay(year,
        start_date = .data$record_keydate1,
        end_date = .data$record_keydate2,
        sc_qtr = .data$sc_latest_submission
      )
    ) %>%
    # Change ch provider to numeric
    dplyr::mutate(
      ch_provider = as.numeric(.data$ch_provider)
    )


  # Costs  ---------------------------------------
  # read in CH Costs Lookup
  ch_costs <- readr::read_rds(get_ch_costs_path()) %>%
    dplyr::rename(
      ch_nursing = "nursing_care_provision"
    )

  # match costs
  matched_costs <- source_ch_clean %>%
    dplyr::left_join(ch_costs, by = c("year", "ch_nursing"))

  monthly_costs <- matched_costs %>%
    # monthly costs
    create_monthly_costs(.data$yearstay, .data$cost_per_day * .data$yearstay) %>%
    # cost total net
    dplyr::mutate(cost_total_net = rowSums(dplyr::across(tidyselect::ends_with("_cost"))))


  # Outfile  ---------------------------------------

  outfile <- monthly_costs %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
      "chi",
      "person_id",
      "dob",
      "gender",
      "postcode",
      "sc_send_lca",
      "record_keydate1",
      "record_keydate2",
      "sc_latest_submission",
      tidyselect::starts_with("ch_"),
      "yearstay",
      "stay",
      "cost_total_net",
      tidyselect::ends_with("_beddays"),
      tidyselect::ends_with("_cost"),
      tidyselect::starts_with("sc_")
    )

  if (write_to_disk) {
    # Save .rds file
    outfile %>%
      write_rds(get_source_extract_path(year, type = "CH", check_mode = "write"))
  }
}