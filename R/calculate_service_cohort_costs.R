#' Calculate costs based on service use cohort
#'
#' @param data A data frame that has service use cohorts assigned
#'
#' @return A data frame with adjusted costs based on cohort
#' @export
#'
#' @family Demographic and Service Use Cohort functions
calculate_service_cohort_costs <- function(data) {
  check_variables_exist(
    data,
    c(
      "elective_inpatient_cohort", "limited_daycases_cohort", "routine_daycase_cohort",
      "single_emergency_cohort", "multiple_emergency_cohort", "community_care_cohort",
      "acute_elective_cost", "acute_emergency_cost", "community_health_cost",
      "cost_total_net"
    )
  )

  return_data <- data %>%
    dplyr::mutate(
      elective_inpatient_cost = dplyr::if_else(.data$elective_inpatient_cohort, .data$acute_elective_cost, 0),
      limited_daycases_cost = dplyr::if_else(.data$limited_daycases_cohort, .data$acute_elective_cost, 0),
      routine_daycase_cost = dplyr::if_else(.data$routine_daycase_cohort, .data$acute_elective_cost, 0),
      single_emergency_cost = dplyr::if_else(.data$single_emergency_cohort, .data$acute_emergency_cost, 0),
      multiple_emergency_cost = dplyr::if_else(.data$multiple_emergency_cohort, .data$acute_emergency_cost, 0),
      # In the future this will be = .data$community_health_cost + .data$home_care_cost
      community_care_cost = dplyr::if_else(.data$community_care_cohort, .data$community_health_cost, 0),
      # Care Home cost is removed for now, so set to zero
      residential_care_cost = 0,
      # Replace any missing total costs with zero
      across(.data$cost_total_net, ~ replace(., is.na(.), 0))
    )

  return(return_data)
}
