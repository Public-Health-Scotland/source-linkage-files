#' Process the (year specific) Care Home extract
#'
#' @description This will read and process the
#' (year specific) Care Home extract, it will return the final data
#' but also write this out as rds.
#'
#' @param data The full processed data which will be selected from to create
#' the year specific data.
#' @param year The year to process, in FY format.
#' @param client_lookup The Social Care Client lookup, created by
#' [process_lookup_sc_client()].
#' @param ch_costs The Care Home costs lookup
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_care_home <- function(
    data,
    year,
    client_lookup,
    ch_costs,
    write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Check that we have data for this year
  if (!check_year_valid(year, "CH")) {
    # If not return an empty tibble
    return(tibble::tibble())
  }

  # Selections for financial year------------------------------------

  ch_data <- data %>%
    # select episodes for FY
    dplyr::filter(
      is_date_in_fyyear(year, .data$record_keydate1, .data$record_keydate2)
    ) %>%
    # remove any episodes where the latest submission was before the current year
    dplyr::filter(
      substr(.data$sc_latest_submission, 1, 4) >= convert_fyyear_to_year(year)
    ) %>%
    # Match to client data
    dplyr::left_join(
      client_lookup,
      by = c("sending_location", "social_care_id")
    )


  # Data Cleaning ---------------------------------------
  source_ch_clean <- ch_data %>%
    # create variables
    dplyr::mutate(
      year = year,
      recid = "CH",
      smrtype = add_smr_type(recid = "CH")
    ) %>%
    # compute lca variable from sending_location
    dplyr::mutate(
      sc_send_lca = convert_sending_location_to_lca(.data$sending_location)
    ) %>%
    # bed days
    create_monthly_beddays(year,
      admission_date = .data$record_keydate1,
      discharge_date = .data$record_keydate2
    ) %>%
    # year stay
    dplyr::mutate(
      yearstay = rowSums(dplyr::pick(dplyr::ends_with("_beddays"))),
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
  matched_costs <- source_ch_clean %>%
    dplyr::left_join(
      ch_costs,
      by = c("year", "ch_nursing" = "nursing_care_provision")
    )

  monthly_costs <- matched_costs %>%
    # Costs are only applied to over 65s - give others NA
    dplyr::mutate(
      age = compute_mid_year_age(year, .data$dob),
      cost_per_day = dplyr::if_else(
        .data$age >= 65L,
        .data$cost_per_day,
        NA_real_
      ),
      # Create monthly beddays works fine here but this reduces the number
      # of calculations and therefore rounding errors.
      dplyr::across(
        .cols = dplyr::ends_with("_beddays"),
        .fns = ~ .x * .data$cost_per_day,
        .names = "{.col}_cost"
      )
    ) %>%
    dplyr::rename_with(
      .cols = dplyr::ends_with("_cost"),
      .fn = ~ stringr::str_remove(.x, "_beddays")
    ) %>%
    dplyr::mutate(
      cost_total_net = .data$cost_per_day * .data$yearstay
    )

  ch_processed <- monthly_costs %>%
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
      dplyr::starts_with("ch_"),
      "yearstay",
      "stay",
      "cost_total_net",
      dplyr::ends_with("_beddays"),
      dplyr::ends_with("_cost"),
      dplyr::starts_with("sc_")
    )

  if (write_to_disk) {
    write_file(
      ch_processed,
      get_source_extract_path(year, type = "CH", check_mode = "write")
    )
  }

  return(ch_processed)
}
