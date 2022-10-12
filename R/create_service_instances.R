#' Create counters for elective and non-elective instances
#'
#' @param data A data frame
#'
#' @return A data frame with four counters, a death flag, and a cost variable for
#' elective inpatients
#' @export
#'
#' @family Demographic and Service Use Cohort functions
create_service_instances <- function(data) {
  check_variables_exist(data, variables = c("cij_marker", "cij_pattype", "cij_ipdc", "cost_total_net"))

  return_data <- data %>%
    dplyr::mutate(
      emergency_instances = .data$cij_pattype == "Non-Elective",
      elective_instances = .data$cij_pattype == "Elective" | .data$cij_ipdc == "D",
      elective_inpatient_instances = .data$cij_pattype == "Elective" & .data$cij_ipdc == "I",
      elective_daycase_instances = .data$cij_pattype == "Elective" & .data$cij_ipdc == "D",
      death_flag = .data$cij_marker == "NRS",
      elective_inpatient_cost = dplyr::if_else(elective_inpatient_instances, cost_total_net, 0)
    )

  return(return_data)
}
