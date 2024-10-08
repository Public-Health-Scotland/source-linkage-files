#' Process the all home care extract
#'
#' @description This will read and process the
#' all home care extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_sc_all_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
#' @export
#'
process_sc_all_home_care <- function(
    data,
    sc_demog_lookup = read_file(get_sc_demog_lookup_path()) %>% slfhelper::get_chi(),
    write_to_disk = TRUE) {
  replaced_dates <- data %>%
    dplyr::filter(.data$hc_start_date_after_period_end_date != 1) %>%
    dplyr::mutate(
      hc_service_end_date = fix_sc_missing_end_dates(
        .data$hc_service_end_date,
        .data$hc_period_end_date
      ), hc_service_start_date = fix_sc_start_dates(
        .data$hc_service_start_date,
        .data$hc_period_start_date
      ),
      # Fix service_end_date is earlier than service_start_date by setting end_date to the end of fy
      hc_service_end_date = fix_sc_end_dates(
        .data$hc_service_start_date,
        .data$hc_service_end_date,
        .data$hc_period_end_date
      )
    )


  # Match on demographic data ---------------------------------------

  matched_hc_data <- replaced_dates %>%
    dplyr::right_join(
      sc_demog_lookup,
      by = c("sending_location", "social_care_id")
    ) %>%
    # when multiple social_care_id from sending_location for single CHI
    # replace social_care_id with latest
    replace_sc_id_with_latest()


  # Data Cleaning ---------------------------------------

  home_care_clean <- matched_hc_data %>%
    # set reablement values == 9 to NA
    dplyr::mutate(reablement = dplyr::na_if(.data$reablement, 9L)) %>%
    # fix NA hc_service
    dplyr::mutate(hc_service = tidyr::replace_na(.data$hc_service, 0L)) %>%
    # fill reablement when missing but present in group
    dplyr::group_by(
      .data$sending_location,
      .data$social_care_id,
      .data$hc_service_start_date
    ) %>%
    tidyr::fill(.data$reablement, .direction = "updown") %>%
    dplyr::mutate(reablement = tidyr::replace_na(.data$reablement, 9L)) %>%
    dplyr::ungroup()


  # Home Care Hours ---------------------------------------

  home_care_hours <- home_care_clean %>%
    dplyr::mutate(
      days_in_quarter = lubridate::time_length(
        lubridate::interval(
          pmax(.data$hc_period_start_date, .data$hc_service_start_date),
          pmin(.data$hc_period_end_date, .data$hc_service_end_date, na.rm = TRUE)
        ),
        "days"
      ) + 1L,
      hc_hours = dplyr::case_when(
        # For A&B 2020/21, use multistaff (min = 1) * staff hours
        .data$sending_location_name == "Argyll and Bute" &
          stringr::str_starts(.data$period, "2020") &
          is.na(.data$hc_hours_derived)
        ~ pmax(1L, multistaff_input) * .data$total_staff_home_care_hours,
        # Angus submit hourly daily instead of weekly hours
        .data$sending_location_name == "Angus" &
          .data$period %in% c("2018Q3", "2018Q4", "2019Q1", "2019Q2", "2019Q3")
        ~ (.data$hc_hours_derived / 7L) * .data$days_in_quarter,
        TRUE ~ .data$hc_hours_derived
      )
    )


  # Home Care Costs ---------------------------------------

  home_care_costs <- read_file(get_hc_costs_path())

  matched_costs <- home_care_hours %>%
    dplyr::left_join(home_care_costs,
      by = c(
        "sending_location_name" = "ca_name",
        "financial_year" = "year"
      )
    ) %>%
    dplyr::mutate(hc_cost = .data$hc_hours * .data$hourly_cost)

  pivoted_hours <- matched_costs %>%
    # Create a copy of the period then pivot the hours on it
    # This creates a new variable per quarter
    # with the hours for that quarter for every record
    dplyr::mutate(hours_submission_quarter = .data$period) %>%
    tidyr::pivot_wider(
      names_from = .data$hours_submission_quarter,
      values_from = c(.data$hc_hours, .data$hc_cost),
      values_fn = sum,
      values_fill = 0L,
      names_sort = TRUE,
      names_glue = "{.value}_{hours_submission_quarter}"
    ) %>%
    # Add in hour variables for the 2017 quarters we don't have
    dplyr::mutate(
      hc_hours_2017Q1 = NA,
      hc_hours_2017Q2 = NA,
      hc_hours_2017Q3 = NA,
      .before = .data$hc_hours_2017Q4
    ) %>%
    dplyr::mutate(
      hc_cost_2017Q1 = NA,
      hc_cost_2017Q2 = NA,
      hc_cost_2017Q3 = NA,
      .before = .data$hc_cost_2017Q4
    ) %>%
    dplyr::full_join(
      # Create the columns we don't have as NA
      tibble(
        # Create columns for the latest year
        hours_submission_quarter = paste0(max(data$financial_year), "Q", 1L:4L),
        hc_hours = NA,
        hc_cost = NA
      ) %>%
        # Pivot them to the same format as the rest of the data
        tidyr::pivot_wider(
          names_from = .data$hours_submission_quarter,
          values_from = c(.data$hc_hours, .data$hc_cost),
          names_glue = "{.value}_{hours_submission_quarter}"
        )
    )

  merge_data <- pivoted_hours %>%
    # group the data to be merged
    dplyr::group_by(
      .data$chi,
      .data$sending_location_name,
      .data$sending_location,
      .data$social_care_id,
      .data$hc_service_start_date,
      .data$hc_service,
      .data$hc_service_provider,
      .data$reablement
    ) %>%
    dplyr::arrange(.data$period) %>%
    dplyr::summarise(
      # Take the latest submitted value
      dplyr::across(c("hc_service_end_date", "hc_period_end_date"), dplyr::last),
      # Store the period for the latest submitted record
      sc_latest_submission = dplyr::last(.data$period),
      # Sum the (quarterly) hours
      dplyr::across(
        c(dplyr::starts_with("hc_hours_"), -"hc_hours_derived"),
        sum
      ),
      dplyr::across(dplyr::starts_with("hc_cost_"), sum),
      # Shouldn't matter as these are all the same
      dplyr::across(c("gender", "dob", "postcode"), dplyr::first)
    ) %>%
    dplyr::ungroup()


  # Create Source variables---------------------------------------

  all_hc_processed <- merge_data %>%
    # rename
    dplyr::rename(
      record_keydate1 = "hc_service_start_date",
      record_keydate2 = "hc_service_end_date",
      hc_reablement = "reablement",
      hc_provider = "hc_service_provider"
    ) %>%
    # year / recid / SMRType variables
    dplyr::mutate(
      recid = "HC",
      smrtype = dplyr::case_when(
        .data$hc_service == 1L ~ "HC-Non-Per",
        .data$hc_service == 2L ~ "HC-Per",
        TRUE ~ "HC-Unknown"
      )
    ) %>%
    # compute lca variable from sending_location
    dplyr::mutate(
      sc_send_lca = convert_sc_sending_location_to_lca(.data$sending_location)
    ) %>%
    slfhelper::get_anon_chi()

  if (write_to_disk) {
    write_file(
      all_hc_processed,
      get_sc_hc_episodes_path(check_mode = "write")
    )
  }

  return(all_hc_processed)
}
