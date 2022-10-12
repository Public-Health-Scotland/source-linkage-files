#' Title Assign service use cohort into string format
#'
#' @param data A data frame
#'
#' @return A data frame with an additional variable containing the assigned cohort
#' @export
#'
#' @family Demographic and Service Use Cohort functions
assign_cohort_names <- function(data) {

  check_variables_exist(data,
                        c("psychiatry_cost", "maternity_cost", "geriatric_cost",
                          "elective_inpatient_cost", "limited_daycases_cost",
                          "routine_daycase_cost", "single_emergency_cost",
                          "multiple_emergency_cost", "prescribing_cost",
                          "outpatient_cost", "ae2_cost", "residential_care_cost"))

  return_data <- data %>%
    dplyr::mutate(
      # Find the highest value among the given cost variables
      cost_max = pmax(
        .data$psychiatry_cost, .data$maternity_cost, .data$geriatric_cost,
        .data$elective_inpatient_cost, .data$limited_daycases_cost,
        .data$routine_daycase_cost, .data$single_emergency_cost,
        .data$multiple_emergency_cost, .data$prescribing_cost,
        .data$outpatient_cost, .data$ae2_cost, .data$residential_care_cost
      ),
      # Assign service use cohort based on highest cost
      service_use_cohort = dplyr::case_when(
        # Situation where no cost is greater than another, so the maxiumum is the same
        # as the mean
        cost_max == rowSums(
          dplyr::across(
            c(.data$psychiatry_cost:.data$residential_care_cost))) / 12 ~ "Unassigned",
        cost_max == .data$psychiatry_cost ~ "Psychiatry",
        cost_max == .data$maternity_cost ~ "Maternity",
        # Geriatric has to be larger or equal to psychiatry
        cost_max == .data$geriatric_cost &
          .data$geriatric_cost >= .data$psychiatry_cost ~ "Geriatric",
        cost_max == .data$elective_inpatient_cost ~ "Elective Inpatient",
        cost_max == .data$limited_daycases_cost ~ "Limited Daycases",
        # Routine daycase has to be larger or equal to outpatient
        cost_max == .data$routine_daycase_cost &
          .data$routine_daycase_cost >= .data$outpatient_cost ~ "Routine Daycase",
        cost_max == .data$single_emergency_cost ~ "Single Emergency",
        cost_max == .data$multiple_emergency_cost ~ "Multiple Emergency",
        cost_max == .data$prescribing_cost ~ "Prescribing",
        cost_max == .data$outpatient_cost ~ "Outpatients",
        # Future: cost_max == .data$community_care_cost ~ "Community Care",
        cost_max == .data$ae2_cost ~ "Unscheduled Care",
        cost_max == .data$residential_care_cost ~ "Residential Care",
        TRUE ~ "Unassigned"
      )
    ) %>%
    dplyr::select(-cost_max)
  return(return_data)
}
