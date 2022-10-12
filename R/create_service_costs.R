#' Create seperate costs for each service type
#'
#' @param data A data frame
#'
#' @return A data frame with 14 additional variables, 13 costs and one flag for operations
#' @export
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
      geriatric_cost = dplyr::if_else(spec %in% c("AB", "G4") | recid %in% c("50B", "GLS"),
        cost_total_net, 0
      ),
      # Maternity
      maternity_cost = dplyr::if_else(recid == "02B" | cij_pattype == "Maternity",
        cost_total_net, 0
      ),
      # Psychiatry
      psychiatry_cost = dplyr::if_else(recid == "04B" & spec != "G4", cost_total_net, 0),
      # Acute Elective
      acute_elective_cost = dplyr::if_else(recid == "01B" & (cij_pattype == "Elective" | cij_ipdc == "D") &
                                             !(spec %in% c("AB")), cost_total_net, 0),
      # Acute Emergency
      acute_emergency_cost = dplyr::if_else(recid == "01B" &
        cij_pattype == "Non-Elective" & !(spec %in% c("AB")),
      cost_total_net, 0
      ),
      # Outpatient
      outpatient_cost = dplyr::if_else(recid == "00B", cost_total_net - geriatric_cost, 0),
      total_outpatient_cost = dplyr::if_else(recid == "00B", cost_total_net, 0),
      # Home Care is not added yet, here is the code for future
      # home_care_cost = dplyr::if_else(recid %in% c("HC-", "HC + ", "INS", "RSP", "MLS", "DC", "CPL"),
      #                                 cost_total_net, 0),
      # Care home
      care_home_cost = dplyr::if_else(recid == "CH", cost_total_net, 0),
      # Hospital elective
      hospital_elective_cost = dplyr::if_else(recid %in% c("01B", "04B", "50B", "GLS") &
        cij_pattype == "Elective",
      cost_total_net, 0
      ),
      # Hospital Emergency
      hospital_emergency_cost = dplyr::if_else(recid %in% c("01B", "04B", "50B", "GLS") &
        cij_pattype == "Non-Elective",
      cost_total_net, 0
      ),
      # Prescribing
      prescribing_cost = dplyr::if_else(recid == "PIS", cost_total_net, 0),
      # A&E
      ae2_cost = dplyr::if_else(recid %in% c("AE2", "OoH", "SAS", "N24"), cost_total_net, 0),
      # Future: Include CMH here
      # Community
      community_health_cost = dplyr::if_else(recid == "DN", cost_total_net, 0),
      # Add a flag if person has had an operation
      operation_flag = !is_missing(op1a),
      # Replace any NA values with 0
      dplyr::across(c(geriatric_cost:community_health_cost), ~ tidyr::replace_na(., 0))
    )

  return(return_data)
}
