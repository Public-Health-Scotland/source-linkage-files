#' Assign service use cohorts based on costs
#'
#' @param data A data frame
#'
#' @return A data frame with 13 cohort variables added
#' @export
#'
#' @family Demographic and Service Use Cohort functions
assign_service_cohorts <- function(data) {

  check_variables_exist(data,
                        c("psychiatry_cost", "maternity_cost", "geriatric_cost",
                          "elective_inpatient_flag", "elective_instances",
                          "emergency_instances", "prescribing_cost",
                          "outpatient_cost", "care_home_cost", "community_health_cost",
                          "ae2_cost"))

  return_data <- data %>%
    dplyr::mutate(
      # Psychiatry
      psychiatry_cohort = .data$psychiatry_cost > 0,
      # Maternity
      maternity_cohort = .data$maternity_cost > 0,
      # Geriatric Medicine
      geriatric_cohort = .data$geriatric_cost > 0,
      # Elective inpatient
      elective_inpatient_cohort = .data$elective_inpatient_flag,
      # Limited and routine daycases
      limited_daycases_cohort = !.data$elective_inpatient_flag & .data$elective_instances <= 3,
      routine_daycase_cohort = !.data$elective_inpatient_flag & .data$elective_instances >= 4,
      # Single and multiple emergency
      single_emergency_cohort = .data$emergency_instances == 1,
      multiple_emergency_cohort = .data$emergency_instances >= 2,
      # Prescribing
      prescribing_cohort = .data$prescribing_cost > 0,
      # For future: residential_care_cohort = .data$care_home_cost > 0
      # Outpatients
      outpatient_cohort = .data$outpatient_cost > 0,
      # Community
      community_care_cohort = .data$care_home_cost > 0 | .data$community_health_cost > 0,
      # A&E
      ae2_cohort = .data$ae2_cost > 0,
      # Assign other cohort if person isn't in any of the above
      other_cohort = rowSums(dplyr::across(.data$psychiatry_cohort:.data$ae2_cohort)) == 0
    )
}
