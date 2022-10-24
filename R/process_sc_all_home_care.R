#' Process the all home care extract
#'
#' @description This will read and process the
#' all home care extract, it will return the final data
#' but also write this out as a rds.
#'
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
process_sc_all_home_care <- function(data, write_to_disk = TRUE) {
  # Match on demographic data ---------------------------------------

  # read in demographic data
  sc_demog <- readr::read_rds(get_sc_demog_lookup_path())

  matched_hc_data <- data %>%
    dplyr::left_join(sc_demog, by = c("sending_location", "social_care_id"))


  # Data Cleaning ---------------------------------------

  # period start and end dates
  period_dates <- matched_hc_data %>%
    dplyr::distinct(.data$period) %>%
    dplyr::mutate(
      record_date = lubridate::yq(.data$period) %m+% lubridate::period(6, "months") %m-% lubridate::days(1),
      qtr_start = lubridate::yq(.data$period) %m+% lubridate::period(3, "months")
    )

  home_care_clean <- matched_hc_data %>%
    # set reablement values == 9 to NA
    dplyr::mutate(reablement = dplyr::na_if(.data$reablement, "9")) %>%
    # fix NA hc_service
    dplyr::mutate(hc_service = tidyr::replace_na(.data$hc_service, "0")) %>%
    # join with dates
    dplyr::left_join(.data$period_dates, by = c("period")) %>%
    # Replace missing start dates with the start of the quarter
    dplyr::mutate(hc_service_start_date = dplyr::if_else(is.na(.data$hc_service_start_date), .data$qtr_start, .data$hc_service_start_date)) %>%
    # Replace really early start dates with start of the quarter
    dplyr::mutate(hc_service_end_date = dplyr::if_else(.data$hc_service_start_date < as.Date("1989-01-01"), .data$qtr_start, .data$hc_service_start_date)) %>%
    # when multiple social_care_id from sending_location for single CHI
    # replace social_care_id with latest
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    dplyr::mutate(latest_sc_id = dplyr::last(.data$social_care_id)) %>%
    # count changed social_care_id
    dplyr::mutate(
      changed_sc_id = dplyr::if_else(!is.na(.data$chi) & .data$social_care_id != .data$latest_sc_id, 1, 0),
      social_care_id = dplyr::if_else(!is.na(.data$chi) & .data$social_care_id != .data$latest_sc_id,
        .data$latest_sc_id, .data$social_care_id
      )
    ) %>%
    dplyr::ungroup() %>%
    # fill reablement when missing but present in group
    dplyr::group_by(.data$sending_location, .data$social_care_id, .data$hc_service_start_date) %>%
    tidyr::fill(.data$reablement, .direction = "updown") %>%
    dplyr::ungroup() %>%
    # Only keep records which have some time in the quarter in which they were submitted
    dplyr::mutate(
      end_before_qtr = .data$qtr_start > .data$hc_service_end_date & !is.na(.data$hc_service_end_date),
      start_after_quarter = .data$record_date < .data$hc_service_start_date,
      # Need to check - as we are potentialsly introducing bad start dates above
      start_after_end = .data$hc_service_start_date > .data$hc_service_end_date & !is.na(.data$hc_service_end_date)
    ) %>%
    dplyr::filter(
      !.data$end_before_qtr,
      !.data$start_after_quarter,
      !.data$start_after_end
    )

  # count changed social_care_id
  home_care_clean %>% dplyr::count(.data$changed_sc_id)


  # Home Care Hours ---------------------------------------

  home_care_hours <- home_care_clean %>%
    dplyr::mutate(
      days_in_quarter = lubridate::time_length(lubridate::interval(
        pmax(.data$qtr_start, .data$hc_service_start_date), pmin(.data$record_date, .data$hc_service_end_date, na.rm = TRUE)
      ), "days") + 1,
      hc_hours = dplyr::case_when(
        # For A&B 2020/21, use multistaff (min = 1) * staff hours
        .data$sending_location_name == "Argyll and Bute" & stringr::str_starts(.data$period, "2020") & is.na(.data$hc_hours_derived)
        ~ pmax(1, multistaff_input) * .data$total_staff_home_care_hours,
        # Angus submit hourly daily instead of weekly hours
        .data$sending_location_name == "Angus" & .data$period %in% c("2018Q3", "2018Q4", "2019Q1", "2019Q2", "2019Q3")
        ~ (.data$hc_hours_derived / 7) * .data$days_in_quarter,
        TRUE ~ .data$hc_hours_derived
      )
    )


  # Home Care Costs ---------------------------------------

  home_care_costs <- readr::read_rds(get_hc_costs_path())

  matched_costs <- home_care_hours %>%
    dplyr::left_join(home_care_costs, by = c("sending_location_name" = "ca_name", "financial_year" = "year")) %>%
    dplyr::mutate(hc_cost = .data$hc_hours * .data$hourly_cost)

  pivotted_hours <- matched_costs %>%
    # Create a copy of the period then pivot the hours on it
    # This creates a new variable per quarter
    # with the hours for that quarter for every record
    dplyr::mutate(hours_submission_quarter = .data$period) %>%
    tidyr::pivot_wider(
      names_from = .data$hours_submission_quarter,
      values_from = c(.data$hc_hours, .data$hc_cost),
      values_fn = sum,
      values_fill = 0,
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
        hours_submission_quarter = paste0(max(data$financial_year), "Q", 1:4),
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


  # Outfile ---------------------------------------

  outfile <- pivotted_hours %>%
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
      dplyr::across(c("hc_service_end_date", "record_date"), dplyr::last),
      # Store the period for the latest submitted record
      sc_latest_submission = dplyr::last(.data$period),
      # Sum the (quarterly) hours
      dplyr::across(tidyselect::starts_with("hc_hours_20"), sum),
      dplyr::across(tidyselect::starts_with("hc_cost_20"), sum),
      # Shouldn't matter as these are all the same
      dplyr::across(c("gender", "dob", "postcode"), dplyr::first)
    ) %>%
    dplyr::ungroup()

  if (write_to_disk) {
    # Save .rds file
    outfile %>%
      write_rds(get_sc_hc_episodes_path(check_mode = "write"))
  }

  return(outfile)
}
