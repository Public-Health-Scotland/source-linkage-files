#' Create the Service Use Cohorts lookup file
#' @param data A data frame
#' @param year The financial year
#' @param write_to_disk Default `TRUE`, will write the lookup to the
#' Cohorts folder defined by [get_slf_dir]
#'
#' @return The service-use cohorts file
#' @export
#'
#' @family Demographic and Service Use Cohort functions
create_service_use_cohorts <- function(data, year, write_to_disk = TRUE) {
  return_data <- data %>%
    # Only select rows with chi
    dplyr::filter(!is_missing(.data$chi)) %>%
    # Create cij_attendance = TRUE when there is a cij_marker,
    # and use recid for cij_marker if there is not a cij_marker
    dplyr::mutate(
      cij_attendance = !is.na(.data$cij_marker),
      cij_marker = dplyr::if_else(is.na(.data$cij_marker),
        .data$recid, as.character(.data$cij_marker)
      ),

      # Calculate service costs
      geriatric_cost = calculate_geriatric_cost(.data$recid, .data$spec, .data$cost_total_net),
      maternity_cost = calculate_maternity_cost(.data$recid, .data$cij_pattype, .data$cost_total_net),
      psychiatry_cost = calculate_psychiatry_cost(.data$recid, .data$spec, .data$cost_total_net),
      acute_elective_cost = calculate_acute_elective_cost(
        .data$recid, .data$cij_pattype, .data$cij_ipdc,
        .data$spec, .data$cost_total_net
      ),
      acute_emergency_cost = calculate_acute_emergency_cost(
        .data$recid, .data$cij_pattype,
        .data$spec, .data$cost_total_net
      ),
      outpatient_cost = calculate_outpatient_costs(.data$recid, .data$cost_total_net, .data$geriatric_cost)[[1]],
      total_outpatient_cost = calculate_outpatient_costs(.data$recid, .data$cost_total_net, .data$geriatric_cost)[[2]],
      care_home_cost = calculate_care_home_cost(.data$recid, .data$cost_total_net),
      hospital_elective_cost = calculate_hospital_elective_cost(.data$recid, .data$cij_pattype, .data$cost_total_net),
      hospital_emergency_cost = calculate_hospital_emergency_cost(.data$recid, .data$cij_pattype, .data$cost_total_net),
      prescribing_cost = calculate_prescribing_cost(.data$recid, .data$cost_total_net),
      ae2_cost = calculate_ae2_cost(.data$recid, .data$cost_total_net),
      community_health_cost = calculate_community_health_cost(.data$recid, .data$cost_total_net),
      operation_flag = add_operation_flag(.data$op1a)
    ) %>%
    # Aggregate to cij-level
    dplyr::group_by(.data$chi, .data$cij_marker, .data$cij_ipdc, .data$cij_pattype) %>%
    dplyr::summarise(
      dplyr::across(c("cost_total_net", "geriatric_cost":"community_health_cost"), sum),
      dplyr::across(c("operation_flag", "cij_attendance"), any)
    ) %>%
    dplyr::ungroup() %>%
    # Create specific instance counters and compute cost for elective inpatients
    dplyr::mutate(
      emergency_instances = assign_emergency_instances(.data$cij_pattype),
      elective_instances = assign_elective_instances(.data$cij_pattype, .data$cij_ipdc),
      elective_inpatient_instances = assign_elective_inpatient_instances(.data$cij_pattype, .data$cij_ipdc),
      elective_daycase_instances = assign_elective_daycase_instances(.data$cij_pattype, .data$cij_ipdc),
      death_flag = assign_death_flag(.data$cij_marker),
      elective_inpatient_cost = calculate_elective_inpatient_cost(
        .data$elective_inpatient_instances,
        .data$cost_total_net
      )
    ) %>%
    # Move flags to end of data frame
    dplyr::relocate(c("operation_flag", "death_flag"), .after = dplyr::last_col()) %>%
    # Aggregate to chi-level
    dplyr::group_by(.data$chi) %>%
    dplyr::summarise(
      dplyr::across(c(.data$cost_total_net:.data$elective_inpatient_cost), sum),
      dplyr::across(c(.data$operation_flag, .data$death_flag), any)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      # Create flag for elective inpatients
      elective_inpatient_flag = assign_elective_inpatient_flag(.data$acute_elective_cost, .data$elective_inpatient_cost),
      # Assign cohort flags
      psychiatry_cohort = assign_psychiatry_cohort(.data$psychiatry_cost),
      maternity_cohort = assign_maternity_cohort(.data$maternity_cost),
      geriatric_cohort = assign_geriatric_cohort(.data$geriatric_cost),
      elective_inpatient_cohort = assign_elective_inpatient_cohort(.data$elective_inpatient_flag),
      limited_daycases_cohort = assign_limited_daycases_cohort(.data$elective_inpatient_flag, .data$elective_instances),
      routine_daycase_cohort = assign_routine_daycase_cohort(.data$elective_inpatient_flag, .data$elective_instances),
      single_emergency_cohort = assign_single_emergency_cohort(.data$emergency_instances),
      multiple_emergency_cohort = assign_multiple_emergency_cohort(.data$emergency_instances),
      prescribing_cohort = assign_prescribing_cohort(.data$prescribing_cost),
      outpatient_cohort = assign_outpatient_cohort(.data$outpatient_cost),
      ae2_cohort = assign_ae2_cohort(.data$ae2_cost),
      community_care_cohort = assign_community_care_cohort(.data$community_health_cost),
      # Assign other cohort if none have been assigned
      other_cohort = rowSums(dplyr::across("psychiatry_cohort":"community_care_cohort")) == 0,

      # Recalculate costs based on the cohorts
      elective_inpatient_cost = recalculate_elective_inpatient_cost(
        .data$elective_inpatient_cohort,
        .data$acute_elective_cost
      ),
      limited_daycases_cost = calculate_limited_daycases_cost(
        .data$limited_daycases_cohort,
        .data$acute_elective_cost
      ),
      routine_daycase_cost = calculate_routine_daycase_cost(
        .data$routine_daycase_cohort,
        .data$acute_elective_cost
      ),
      single_emergency_cost = calculate_single_emergency_cost(
        .data$single_emergency_cohort,
        .data$acute_emergency_cost
      ),
      multiple_emergency_cost = calculate_multiple_emergency_cost(
        .data$multiple_emergency_cohort,
        .data$acute_emergency_cost
      ),
      community_care_cost = calculate_community_care_cost(
        .data$community_care_cohort,
        .data$community_health_cost
      ),
      # Care Home cost is removed for now, so set to zero
      residential_care_cost = calculate_residential_care_cost(),
      # Replace any missing total costs with zero
      dplyr::across("cost_total_net", ~ replace(., is.na(.), 0))
    ) %>%
    # Add the cohort names
    assign_cohort_names() %>%
    # Select out the required variables
    dplyr::select(
      "chi",
      "service_use_cohort",
      "psychiatry_cost",
      "maternity_cost",
      "geriatric_cost",
      "elective_inpatient_cost",
      "limited_daycases_cost",
      "single_emergency_cost",
      "multiple_emergency_cost",
      "routine_daycase_cost",
      "outpatient_cost",
      "prescribing_cost",
      "ae2_cost"
    )

  if (write_to_disk) {
    write_rds(return_data,
      path = get_service_use_cohorts_path(year)
    )
  }

  return(return_data)
}

#' Calculate cost for Geriatric Care records
#' @description A record is considered to have a Geriatric Care cost if
#' \itemize{\item It has a recid of 50B or GLS
#'          \item It has a specialty of AB (Geriatric Medicine)
#'                or G4 (Psychiatry of Old Age)}
#'
#' @param recid A vector of record IDs
#' @param spec A vector of specialty codes
#' @param cost_total_net A vector of total net costs
#'
#' @return A vector of Geriatric Care costs
#' @family Demographic and Service Use Cohort functions
calculate_geriatric_cost <- function(recid, spec, cost_total_net) {
  geriatric_cost <- dplyr::if_else(
    .data$recid %in% c("50B", "GLS") | .data$spec %in% c("AB", "G4"), .data$cost_total_net, 0
  )
  return(geriatric_cost)
}

#' Calculate cost for Maternity records
#' @description A record is considered to have a Maternity cost if the recid is
#' 02B or the cij_pattype is "Maternity"
#'
#' @param recid A vector of record IDs
#' @param cij_pattype A vector of CIJ patient types
#' @param cost_total_net A vector of total net costs
#'
#' @return A vector of Maternity costs
#' @family Demographic and Service Use Cohort functions
calculate_maternity_cost <- function(recid, cij_pattype, cost_total_net) {
  maternity_cost <- dplyr::if_else(
    recid == "02B" | cij_pattype == "Maternity", cost_total_net, 0
  )
  return(maternity_cost)
}

#' Calculate cost for Psychiatry records
#' @description A record is considered to have a Psychiatry cost if the recid is 04B
#' and the specialty is not G4
#'
#' @inheritParams calculate_geriatric_cost
#'
#' @return A vector of Psychiatry costs
#' @family Demographic and Service Use Cohort functions
calculate_psychiatry_cost <- function(recid, spec, cost_total_net) {
  psychiatry_cost <- dplyr::if_else(
    recid == "04B" & spec != "G4", cost_total_net, 0
  )
  return(psychiatry_cost)
}

#' Calculate cost for Acute Elective records
#' @description A record is considered to have an Acute Elective cost if
#' the recid is 01B, the CIJ patient type is Elective or the IPDC shows it is a day case,
#' and the specialty is not AB
#'
#' @inheritParams calculate_geriatric_cost
#' @param cij_pattype A vector of CIJ patient types
#' @param cij_ipdc A vector of CIJ inpatient/daycase markers
#'
#' @return A vector of Acute Elective costs
#' @family Demographic and Service Use Cohort functions
calculate_acute_elective_cost <- function(recid, cij_pattype, cij_ipdc, spec, cost_total_net) {
  acute_elective_cost <- dplyr::if_else(recid == "01B" &
    (cij_pattype == "Elective" | cij_ipdc == "D") &
    spec != "AB", cost_total_net, 0)
  return(acute_elective_cost)
}

#' Calculate cost for Acute Emergency records
#' @description A record is considered to have an Acute Emergency cost if
#' the recid is 01B, the CIJ patient type is Non-Elective, and the specialty is not AB
#'
#' @inheritParams calculate_geriatric_cost
#' @param cij_pattype A vector of CIJ patient types
#'
#' @return A vector of Acute Emergency costs
#' @family Demographic and Service Use Cohort functions
calculate_acute_emergency_cost <- function(recid, cij_pattype, spec, cost_total_net) {
  acute_emergency_cost <- dplyr::if_else(recid == "01B" & cij_pattype == "Non-Elective" &
    spec != "AB", cost_total_net, 0)
  return(acute_emergency_cost)
}

#' Calculate cost for Outpatient records
#' @description A record is considered to have an Outpatient cost if the recid is 00B. The
#' Outpatient Cost is defined as (total net cost - geriatric cost), and the Total Outpatient Cost
#' is the total net cost
#'
#' @param recid A vector of record IDs
#' @param cost_total_net A vector of total net costs
#' @param geriatric_cost A vector of geriatric care costs
#'
#' @return A list with outpatient costs in index 1 and total outpatient costs in index 2
#' @family Demographic and Service Use Cohort functions
calculate_outpatient_costs <- function(recid, cost_total_net, geriatric_cost) {
  outpatient_cost <- dplyr::if_else(
    recid == "00B", cost_total_net - geriatric_cost, 0
  )
  total_outpatient_cost <- dplyr::if_else(
    recid == "00B", cost_total_net, 0
  )
  return(list(
    outpatient_cost = outpatient_cost,
    total_outpatient_cost = total_outpatient_cost
  ))
}

#' Calculate cost for Home Care records
#' @description Please note: this function is currently not in use.
#' A record is considered to have a home care cost if the recid is in
#' c("HC-", "HC + ", "INS", "RSP", "MLS", "DC", "CPL")
#'
#' @param recid A vector of record IDs
#' @param cost_total_net A vector of total net costs
#'
#' @return A vector of home care costs
#' @family Demographic and Service Use Cohort functions
calculate_home_care_cost <- function(recid, cost_total_net) {
  home_care_cost <- dplyr::if_else(
    recid %in% c("HC-", "HC + ", "INS", "RSP", "MLS", "DC", "CPL"), cost_total_net, 0
  )
  return(home_care_cost)
}


#' Calculate cost for Care Home records
#' @description A record is considered to have a home care cost if the recid is CH
#'
#' @param recid A vector of record IDs
#' @param cost_total_net A vector of total net costs
#'
#' @return A vector of care home costs
#' @family Demographic and Service Use Cohort functions
calculate_care_home_cost <- function(recid, cost_total_net) {
  care_home_cost <- dplyr::if_else(recid == "CH", cost_total_net, 0)
  return(care_home_cost)
}

#' Calculate cost for Hospital Elective records
#' @description A record is considered to have a Hospital Elective cost if the recid is
#' in c("01B", "04B", "50B", "GLS") and the CIJ patient type is Elective
#'
#' @param recid A vector of record IDs
#' @param cij_pattype A vector of CIJ patient types
#' @param cost_total_net A vector of total net costs
#'
#' @return A vector of Hospital Elective costs
#' @family Demographic and Service Use Cohort functions
calculate_hospital_elective_cost <- function(recid, cij_pattype, cost_total_net) {
  hospital_elective_cost <- dplyr::if_else(
    recid %in% c("01B", "04B", "50B", "GLS") & cij_pattype == "Elective", cost_total_net, 0
  )
  return(hospital_elective_cost)
}

#' Calculate cost for Hospital Emergency records
#' @description A record is considered to have a Hospital Emergency cost if the recid is
#' in c("01B", "04B", "50B", "GLS") and the CIJ patient type is Non-Elective
#'
#' @inheritParams calculate_hospital_elective_cost
#'
#' @return A vector of Hospital Emergency costs
#' @family Demographic and Service Use Cohort functions
calculate_hospital_emergency_cost <- function(recid, cij_pattype, cost_total_net) {
  hospital_emergency_cost <- dplyr::if_else(
    recid %in% c("01B", "04B", "50B", "GLS") & cij_pattype == "Non-Elective", cost_total_net, 0
  )
  return(hospital_emergency_cost)
}

#' Calculate cost for Prescribing records
#' @description A record is considered to have a Prescribing cost if the recid is PIS
#'
#' @param recid A vector of record IDs
#' @param cost_total_net A vector of total net costs
#'
#' @return A vector of Prescribing costs
#' @family Demographic and Service Use Cohort functions
calculate_prescribing_cost <- function(recid, cost_total_net) {
  prescribing_cost <- dplyr::if_else(recid == "PIS", cost_total_net, 0)
  return(prescribing_cost)
}

#' Calculate cost for Accident & Emergency records
#' @description A record is considered to have an A&E cost if the recid is one of
#' "AE2", "OoH", "SAS", or "N24"
#'
#' @inheritParams calculate_prescribing_cost
#'
#' @return A vector of A&E costs
#' @family Demographic and Service Use Cohort functions
calculate_ae2_cost <- function(recid, cost_total_net) {
  ae2_cost <- dplyr::if_else(recid %in% c("AE2", "OoH", "SAS", "N24"), cost_total_net, 0)
  return(ae2_cost)
}

#' Calculate cost for Community Health records
#' @description A record is considered to have a Community Health cost if the recid is DN
#'
#' @inheritParams calculate_prescribing_cost
#'
#' @return A vector of Community Health costs
#' @family Demographic and Service Use Cohort functions
calculate_community_health_cost <- function(recid, cost_total_net) {
  community_health_cost <- dplyr::if_else(recid == "DN", cost_total_net, 0)
  return(community_health_cost)
}

#' Calculate cost for Elective Inpatient records
#'
#' @param elective_inpatient_instances A vector of elective inpatient instances
#' @param cost_total_net A vector of total net costs
#'
#' @return A vector of elective inpatient costs
#' @seealso [assign_elective_inpatient_instances()]
#' @family Demographic and Service Use Cohort functions
calculate_elective_inpatient_cost <- function(elective_inpatient_instances, cost_total_net) {
  elective_inpatient_cost <- dplyr::if_else(
    elective_inpatient_instances, cost_total_net, 0
  )
  return(elective_inpatient_cost)
}

#' Add operation flag
#'
#' @param op1a A vector of operation codes
#'
#' @return A boolean vector showing whether a record contains an operation or not
#' @family Demographic and Service Use Cohort functions
add_operation_flag <- function(op1a) {
  operation_flag <- !is_missing(op1a)
  return(operation_flag)
}

#' Assign a flag for emergency instances
#' @description An emergency instance is defined as when the CIJ patient type is
#' Non-Elective
#'
#' @param cij_pattype A vector of CIJ patient types
#'
#' @return A boolean vector showing whether a record is an emergency or not
#' @family Demographic and Service Use Cohort functions
assign_emergency_instances <- function(cij_pattype) {
  emergency_instances <- cij_pattype == "Non-Elective"
  return(emergency_instances)
}

#' Assign a flag for elective instances
#' @description An elective instance is defined as when the CIJ patient type is
#' Elective and the IPDC marker is D
#'
#' @param cij_pattype A vector of CIJ patient types
#' @param cij_ipdc A vector of CIJ IPDC markers
#'
#' @return A boolean vector showing whether a record is an elective case or not
#' @family Demographic and Service Use Cohort functions
assign_elective_instances <- function(cij_pattype, cij_ipdc) {
  elective_instances <- cij_pattype == "Elective" | cij_ipdc == "D"
  return(elective_instances)
}

#' Assign a flag for elective inpatient instances
#' @description An elective inpatient instance is defined as when the CIJ patient type is
#' Elective and the IPDC marker is I
#'
#' @inheritParams assign_elective_instances
#'
#' @return A boolean vector showing whether a record is an elective inpatient case or not
#' @family Demographic and Service Use Cohort functions
assign_elective_inpatient_instances <- function(cij_pattype, cij_ipdc) {
  elective_inpatient_instances <- cij_pattype == "Elective" & cij_ipdc == "I"
  return(elective_inpatient_instances)
}

#' Assign a flag for elective daycase instances
#' @description An elective daycase instance is defined as when the CIJ patient type is
#' Elective and the IPDC marker is D
#'
#' @inheritParams assign_elective_instances
#'
#' @return A boolean vector showing whether a record is an elective inpatient case or not
#' @family Demographic and Service Use Cohort functions
assign_elective_daycase_instances <- function(cij_pattype, cij_ipdc) {
  elective_daycase_instances <- cij_pattype == "Elective" & cij_ipdc == "D"
  return(elective_daycase_instances)
}

#' Assign a flag for elective inpatients
#' @description In this case, an elective inpatient is flagged if over half of the acute elective
#' cost is for elective inpatient procedures
#'
#' @param acute_elective_cost a vector
#' @param elective_inpatient_cost a vector
#'
#' @return A boolean vector indicating whether a record is an elective inpatient one
#' @family Demographic and Service Use Cohort functions
assign_elective_inpatient_flag <- function(acute_elective_cost, elective_inpatient_cost) {
  elective_inpatient_percentage <- dplyr::if_else(
    acute_elective_cost > 0, elective_inpatient_cost / acute_elective_cost, 0
  )

  elective_inpatient_flag <- elective_inpatient_percentage > 0.5

  return(elective_inpatient_flag)
}

#' Assign a flag for deaths
#' @description A death in this case is marked when the cij_marker is NRS
#'
#' @param cij_marker A vector of CIJ markers
#'
#' @return A boolean vector of death flags
#' @family Demographic and Service Use Cohort functions
assign_death_flag <- function(cij_marker) {
  death_flag <- cij_marker == "NRS"
  return(death_flag)
}

#' Assign psychiatry cohort flag
#' @description If the record has a psychiatry cost greater than zero, assign `TRUE`
#'
#' @param psychiatry_cost A vector of psychiatry costs
#'
#' @return A boolean vector of psychiatry cohort flags
#' @family Demographic and Service Use Cohort functions
assign_psychiatry_cohort <- function(psychiatry_cost) {
  psychiatry_cohort <- psychiatry_cost > 0
  return(psychiatry_cohort)
}

#' Assign maternity cohort flag
#' @description If the record has a maternity cost greater than zero, assign `TRUE`
#'
#' @param maternity_cost A vector of maternity costs
#'
#' @return A boolean vector of maternity cohort flags
#' @family Demographic and Service Use Cohort functions
assign_maternity_cohort <- function(maternity_cost) {
  maternity_cohort <- maternity_cost > 0
  return(maternity_cohort)
}

#' Assign geriatric cohort flag
#' @description If the record has a geriatric cost greater than zero, assign `TRUE`
#'
#' @param geriatric_cost A vector of geriatric costs
#'
#' @return A boolean vector of geriatric cohort flags
#' @family Demographic and Service Use Cohort functions
assign_geriatric_cohort <- function(geriatric_cost) {
  geriatric_cohort <- geriatric_cost > 0
  return(geriatric_cohort)
}

#' Assign elective inpatient cohort flag
#' @description If the record has a elective inpatient flag, assign `TRUE`
#'
#' @param elective_inpatient_flag A vector of elective_inpatient costs
#'
#' @return A boolean vector of elective inpatient cohort flags
#' @family Demographic and Service Use Cohort functions
assign_elective_inpatient_cohort <- function(elective_inpatient_flag) {
  elective_inpatient_cohort <- elective_inpatient_flag
  return(elective_inpatient_cohort)
}

#' Assign limited daycases cohort flag
#' @description If the record does not have an elective inpatient flag and they have
#' 3 or fewer elective instances, return `TRUE`
#'
#' @param elective_inpatient_flag A vector of elective inpatient flags
#' @param elective_instances A vector of elective instances
#'
#' @return A boolean vector of limited daycases cohort flags
#' @family Demographic and Service Use Cohort functions
assign_limited_daycases_cohort <- function(elective_inpatient_flag, elective_instances) {
  limited_daycases_cohort <- !elective_inpatient_flag & elective_instances <= 3
  return(limited_daycases_cohort)
}

#' Assign routine daycase cohort flag
#' @description If the record does not have an elective inpatient flag and they have
#' 4 or more elective instances, return `TRUE`
#'
#' @inheritParams assign_limited_daycases_cohort
#'
#' @return A boolean vector of routine daycase cohort flags
#' @family Demographic and Service Use Cohort functions
assign_routine_daycase_cohort <- function(elective_inpatient_flag, elective_instances) {
  routine_daycase_cohort <- !elective_inpatient_flag & elective_instances >= 4
  return(routine_daycase_cohort)
}

#' Assign single emergency cohort flag
#'
#' @param emergency_instances A vector of emergency instances
#'
#' @return A boolean vector of single emergency cohort flags
#' @family Demographic and Service Use Cohort functions
assign_single_emergency_cohort <- function(emergency_instances) {
  single_emergency_cohort <- emergency_instances == 1
  return(single_emergency_cohort)
}

#' Assign multiple emergency cohort flag
#'
#' @inheritParams assign_single_emergency_cohort
#'
#' @return A boolean vector of multiple emergency cohort flags
#' @family Demographic and Service Use Cohort functions
assign_multiple_emergency_cohort <- function(emergency_instances) {
  multiple_emergency_cohort <- emergency_instances >= 2
  return(multiple_emergency_cohort)
}

#' Assign prescribing cohort flag
#' @description If the record has a prescribing cost greater than zero, assign `TRUE`
#'
#' @param prescribing_cost A vector of prescribing costs
#'
#' @return A boolean vector of prescribing cohort flags
#' @family Demographic and Service Use Cohort functions
assign_prescribing_cohort <- function(prescribing_cost) {
  prescribing_cohort <- prescribing_cost > 0
  return(prescribing_cohort)
}

#' Assign outpatient cohort flag
#' @description If the record has a outpatient cost greater than zero, assign `TRUE`
#'
#' @param outpatient_cost A vector of outpatient costs
#'
#' @return A boolean vector of outpatient cohort flags
#' @family Demographic and Service Use Cohort functions
assign_outpatient_cohort <- function(outpatient_cost) {
  outpatient_cohort <- outpatient_cost > 0
  return(outpatient_cohort)
}

#' Assign residential care cohort flag
#' @description Please note that this function is not currently in use
#' If the record has a care home cost greater than zero, assign `TRUE`
#'
#' @param care_home_cost A vector of care home costs
#'
#' @return A boolean vector of residential care cohort flags
#' @family Demographic and Service Use Cohort functions
assign_residential_care_cohort <- function(care_home_cost) {
  residential_care_cohort <- care_home_cost > 0
  return(residential_care_cohort)
}

#' Assign A&E cohort flag
#' @description If the record has a A&E cost greater than zero, assign `TRUE`
#'
#' @param ae2_cost A vector of A&E costs
#'
#' @return A boolean vector of A&E cohort flags
#' @family Demographic and Service Use Cohort functions
assign_ae2_cohort <- function(ae2_cost) {
  ae2_cohort <- ae2_cost > 0
  return(ae2_cohort)
}

#' Assign Community Care cohort flag
#' @description If the record has a home care cost or community health
#' cost greater than zero, assign `TRUE`
#'
#' @param community_health_cost A vector of community health costs
#'
#' @return A boolean vector of Community Care cohort flags
#' @family Demographic and Service Use Cohort functions
assign_community_care_cohort <- function(community_health_cost) {
  community_care_cohort <- community_health_cost > 0 # | home_care_cost > 0
  return(community_care_cohort)
}

#' Recalculate elective inpatient costs
#' @description Elective inpatient costs need to be recalculated
#' once the cohorts have been assigned
#'
#' @param elective_inpatient_cohort A vector of elective inpatient cohort flags
#' @param acute_elective_cost A vector of acute elective costs
#'
#' @return A vector of elective inpatient costs
#' @family Demographic and Service Use Cohort functions
recalculate_elective_inpatient_cost <- function(elective_inpatient_cohort, acute_elective_cost) {
  elective_inpatient_cost <- dplyr::if_else(elective_inpatient_cohort, acute_elective_cost, 0)
  return(elective_inpatient_cost)
}

#' Calculate limited daycases cost
#'
#' @param limited_daycases_cohort A vector of limited daycases cohort flags
#' @param acute_elective_cost A vector of acute elective costs
#'
#' @return A vector of limited daycase costs
#' @family Demographic and Service Use Cohort functions
calculate_limited_daycases_cost <- function(limited_daycases_cohort, acute_elective_cost) {
  limited_daycases_cost <- dplyr::if_else(limited_daycases_cohort, acute_elective_cost, 0)
  return(limited_daycases_cost)
}

#' Calculate routine daycase cost
#'
#' @param routine_daycase_cohort A vector of routine daycase cohort flags
#' @param acute_elective_cost A vector of acute elective costs
#'
#' @return A vector of routine daycase costs
#' @family Demographic and Service Use Cohort functions
calculate_routine_daycase_cost <- function(routine_daycase_cohort, acute_elective_cost) {
  routine_daycase_cost <- dplyr::if_else(routine_daycase_cohort, acute_elective_cost, 0)
  return(routine_daycase_cost)
}

#' Calculate single emergency cost
#'
#' @param single_emergency_cohort A vector of single emergency cohort flags
#' @param acute_emergency_cost A vector of acute emergency costs
#'
#' @return A vector of single emergency costs
#' @family Demographic and Service Use Cohort functions
calculate_single_emergency_cost <- function(single_emergency_cohort, acute_emergency_cost) {
  single_emergency_cost <- dplyr::if_else(single_emergency_cohort, acute_emergency_cost, 0)
  return(single_emergency_cost)
}

#' Calculate multiple emergency cost
#'
#' @param multiple_emergency_cohort A vector of multiple emergency cohort flags
#' @param acute_emergency_cost A vector of acute emergency costs
#'
#' @return A vector of multiple emergency costs
#' @family Demographic and Service Use Cohort functions
calculate_multiple_emergency_cost <- function(multiple_emergency_cohort, acute_emergency_cost) {
  multiple_emergency_cost <- dplyr::if_else(multiple_emergency_cohort, acute_emergency_cost, 0)
  return(multiple_emergency_cost)
}

#' Calculate community care cost
#'
#' @param community_care_cohort A vector of community care cohort flags
#' @param community_health_cost A vector of community health costs
#'
#' @return A vector of community care costs
#' @family Demographic and Service Use Cohort functions
calculate_community_care_cost <- function(community_care_cohort, community_health_cost) {
  community_care_cost <- dplyr::if_else(
    community_care_cohort, community_health_cost, 0
  )
  # FOR FUTURE
  # community_care_cost <- dplyr::if_else(
  # community_care_cohort + home_care_cost, community_health_cost, 0)
  return(community_care_cost)
}

#' Calculate residential care cost
#' @description This function currenly sets these costs to zero
#'
#' @return A vector of community care costs, currently zero
#' @family Demographic and Service Use Cohort functions
calculate_residential_care_cost <- function() {
  residential_care_cost <- 0
  return(residential_care_cost)
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
    dplyr::select(-"cost_max")
  return(return_data)
}
