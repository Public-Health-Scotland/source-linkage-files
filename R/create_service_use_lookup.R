#' Create the Service Use Cohort lookup file
#'
#' @param data A data frame
#' @param year The financial year
#' @param write_to_disk Default `TRUE`, will write the lookup to the
#' Cohorts folder defined by [get_slf_dir]
#'
#' @return The Service Use lookup file
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
      dplyr::across(c(.data$cost_total_net:.data$elective_inpatient_cost), sum),
      dplyr::across(c(.data$operation_flag, .data$death_flag), any)
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

#' Create seperate costs for each service type
#'
#' @param data A data frame
#'
#' @return A data frame with 14 additional variables, 13 costs and one flag for operations
#'
#' @family Demographic and Service Use Cohort functions
create_service_costs <- function(data) {

  # Check data has required variables
  check_variables_exist(data,
    variables =
      c("chi", "recid", "cij_pattype", "cij_ipdc", "spec", "op1a", "cost_total_net")
  )

  return_data <- data %>%
    # Create cost variables based on service use
    # Specialty AB = Geriatric Medicine, G4 = Psychiatry of Old Age
    dplyr::mutate(
      # Geriatric medicine
      geriatric_cost = dplyr::if_else(.data$spec %in% c("AB", "G4") |
        .data$recid %in% c("50B", "GLS"),
      .data$cost_total_net, 0
      ),
      # Maternity
      maternity_cost = dplyr::if_else(.data$recid == "02B" |
        .data$cij_pattype == "Maternity",
      .data$cost_total_net, 0
      ),
      # Psychiatry
      psychiatry_cost = dplyr::if_else(.data$recid == "04B" &
        .data$spec != "G4", .data$cost_total_net, 0),
      # Acute Elective
      acute_elective_cost = dplyr::if_else(.data$recid == "01B" &
        (.data$cij_pattype == "Elective" | .data$cij_ipdc == "D") &
        !(.data$spec %in% c("AB")), .data$cost_total_net, 0),
      # Acute Emergency
      acute_emergency_cost = dplyr::if_else(.data$recid == "01B" &
        .data$cij_pattype == "Non-Elective" & !(.data$spec %in% c("AB")),
      .data$cost_total_net, 0
      ),
      # Outpatient
      outpatient_cost = dplyr::if_else(.data$recid == "00B", .data$cost_total_net - .data$geriatric_cost, 0),
      total_outpatient_cost = dplyr::if_else(.data$recid == "00B", .data$cost_total_net, 0),
      # Home Care is not added yet, here is the code for future
      # home_care_cost = dplyr::if_else(.data$recid %in% c("HC-", "HC + ", "INS", "RSP", "MLS", "DC", "CPL"),
      #                                 .data$cost_total_net, 0),
      # Care home
      care_home_cost = dplyr::if_else(.data$recid == "CH", .data$cost_total_net, 0),
      # Hospital elective
      hospital_elective_cost = dplyr::if_else(.data$recid %in% c("01B", "04B", "50B", "GLS") &
        .data$cij_pattype == "Elective",
      .data$cost_total_net, 0
      ),
      # Hospital Emergency
      hospital_emergency_cost = dplyr::if_else(.data$recid %in% c("01B", "04B", "50B", "GLS") &
        .data$cij_pattype == "Non-Elective",
      .data$cost_total_net, 0
      ),
      # Prescribing
      prescribing_cost = dplyr::if_else(.data$recid == "PIS", .data$cost_total_net, 0),
      # A&E
      ae2_cost = dplyr::if_else(.data$recid %in% c("AE2", "OoH", "SAS", "N24"), .data$cost_total_net, 0),
      # Future: Include CMH here
      # Community
      community_health_cost = dplyr::if_else(.data$recid == "DN", .data$cost_total_net, 0),
      # Add a flag if person has had an operation
      operation_flag = !is_missing(.data$op1a),
      # Replace any NA values with 0
      dplyr::across(c(.data$geriatric_cost:.data$community_health_cost), ~ tidyr::replace_na(., 0))
    )

  return(return_data)
}

#' Create counters for elective and non-elective instances
#'
#' @param data A data frame
#'
#' @return A data frame with four counters, a death flag, and a cost variable for
#' elective inpatients
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
      elective_inpatient_cost = dplyr::if_else(.data$elective_inpatient_instances, .data$cost_total_net, 0)
    )

  return(return_data)
}

#' Assign service use cohorts based on costs
#'
#' @param data A data frame
#'
#' @return A data frame with 13 cohort variables added
#'
#' @family Demographic and Service Use Cohort functions
assign_service_cohorts <- function(data) {
  check_variables_exist(
    data,
    c(
      "psychiatry_cost", "maternity_cost", "geriatric_cost",
      "elective_inpatient_flag", "elective_instances",
      "emergency_instances", "prescribing_cost",
      "outpatient_cost", "care_home_cost", "community_health_cost",
      "ae2_cost"
    )
  )

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

#' Calculate costs based on service use cohort
#'
#' @param data A data frame that has service use cohorts assigned
#'
#' @return A data frame with adjusted costs based on cohort
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
      dplyr::across(.data$cost_total_net, ~ replace(., is.na(.), 0))
    )

  return(return_data)
}

#' Title Assign service use cohort into string format
#'
#' @param data A data frame
#'
#' @return A data frame with an additional variable containing the assigned cohort
#'
#' @family Demographic and Service Use Cohort functions
assign_cohort_names <- function(data) {
  check_variables_exist(
    data,
    c(
      "psychiatry_cost", "maternity_cost", "geriatric_cost",
      "elective_inpatient_cost", "limited_daycases_cost",
      "routine_daycase_cost", "single_emergency_cost",
      "multiple_emergency_cost", "prescribing_cost",
      "outpatient_cost", "ae2_cost", "residential_care_cost"
    )
  )

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
        .data$cost_max == rowSums(
          dplyr::across(
            c(.data$psychiatry_cost:.data$residential_care_cost)
          )
        ) / 12 ~ "Unassigned",
        .data$cost_max == .data$psychiatry_cost ~ "Psychiatry",
        .data$cost_max == .data$maternity_cost ~ "Maternity",
        # Geriatric has to be larger or equal to psychiatry
        .data$cost_max == .data$geriatric_cost &
          .data$geriatric_cost >= .data$psychiatry_cost ~ "Geriatric",
        .data$cost_max == .data$elective_inpatient_cost ~ "Elective Inpatient",
        .data$cost_max == .data$limited_daycases_cost ~ "Limited Daycases",
        # Routine daycase has to be larger or equal to outpatient
        .data$cost_max == .data$routine_daycase_cost &
          .data$routine_daycase_cost >= .data$outpatient_cost ~ "Routine Daycase",
        .data$cost_max == .data$single_emergency_cost ~ "Single Emergency",
        .data$cost_max == .data$multiple_emergency_cost ~ "Multiple Emergency",
        .data$cost_max == .data$prescribing_cost ~ "Prescribing",
        .data$cost_max == .data$outpatient_cost ~ "Outpatients",
        # Future: cost_max == .data$community_care_cost ~ "Community Care",
        .data$cost_max == .data$ae2_cost ~ "Unscheduled Care",
        .data$cost_max == .data$residential_care_cost ~ "Residential Care",
        TRUE ~ "Unassigned"
      )
    ) %>%
    dplyr::select(-.data$cost_max)
  return(return_data)
}
