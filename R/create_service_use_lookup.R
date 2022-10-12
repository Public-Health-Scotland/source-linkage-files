#' Title Create the Service Use Cohort lookup file
#'
#' @param data A data frame
#' @param year The financial year
#' @param write_to_disk Default [TRUE]
#'
#' @return Either save out a copy of the lookup, or return it for checks
#' @export
#'
#' @family Demographic and Service Use Cohort functions
#' @seealso \itemize{\item [create_service_costs()]
#' \item [create_service_instances()]
#' \item [assign_service_cohorts()]
#' \item [calculate_service_cohort_costs()]
#' \item [assign_cohort_names()]}
create_service_use_lookup <- function(data, year, write_to_disk = TRUE) {
  return_data <- data %>%
    # Only select rows with chi
    dplyr::filter(!is_missing(.data$chi)) %>%
    # Create the cost variables for different services
    create_service_costs() %>%
    # Create cij_attendance = TRUE when there is a cij_marker,
    # and use recid for cij_marker if there is not a cij_marker
    dplyr::mutate(
      cij_attendance = !is.na(.data$cij_marker),
      cij_marker = dplyr::if_else(is.na(.data$cij_marker),
        .data$recid, as.character(.data$cij_marker)
      )
    ) %>%
    # Aggregate to cij-level
    dplyr::group_by(.data$chi, .data$cij_marker, .data$cij_ipdc, .data$cij_pattype) %>%
    dplyr::summarise(
      dplyr::across(c(.data$cost_total_net, .data$geriatric_cost:.data$community_health_cost), sum),
      dplyr::across(c(.data$operation_flag, .data$cij_attendance), any)
    ) %>%
    dplyr::ungroup() %>%
    # Create specific instance counters and compute cost for elective inpatients
    create_service_instances() %>%
    dplyr::relocate(c("operation_flag", "death_flag"), .after = dplyr::last_col()) %>%
    # Aggregate to chi-level
    dplyr::group_by(.data$chi) %>%
    dplyr::summarise(
      across(c(.data$cost_total_net:.data$elective_inpatient_cost), sum),
      across(c(.data$operation_flag, .data$death_flag), any)
    ) %>%
    dplyr::ungroup() %>%
    # Create flag for elective inpatients
    dplyr::mutate(
      elective_inpatient_percentage = dplyr::if_else(.data$acute_elective_cost > 0,
        .data$elective_inpatient_cost / .data$acute_elective_cost, 0
      ),
      elective_inpatient_flag = .data$elective_inpatient_percentage > 0.5
    ) %>%
    # Assign service use cohorts
    assign_service_cohorts() %>%
    # Calculate costs based on the cohorts
    calculate_service_cohort_costs() %>%
    # Add the cohort names
    assign_cohort_names() %>%
    # Select out the required variables
    dplyr::select(
      .data$chi,
      .data$service_use_cohort,
      .data$psychiatry_cost,
      .data$maternity_cost,
      .data$geriatric_cost,
      .data$elective_inpatient_cost,
      .data$limited_daycases_cost,
      .data$single_emergency_cost,
      .data$multiple_emergency_cost,
      .data$routine_daycase_cost,
      .data$outpatient_cost,
      .data$prescribing_cost,
      .data$ae2_cost
    )

  if (write_to_disk == TRUE) {
    write_rds(return_data,
      path = glue::glue("{get_slf_dir()}/Cohorts/Service_Use_Cohorts_{year}.rds")
    )
  } else {
    return(return_data)
  }
}
