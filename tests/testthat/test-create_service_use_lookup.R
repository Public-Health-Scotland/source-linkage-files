test_that("Costs are assigned correctly", {
  # Create some dummy data
  dummy_data <- tibble::tribble(
    ~chi, ~recid, ~cij_pattype, ~cij_ipdc, ~spec, ~op1a, ~cost_total_net,
    # Geriatric
    "1", "50B", NA, NA, NA, NA, 1,
    "2", NA, NA, NA, "AB", NA, 1,
    # Maternity
    "3", "02B", NA, NA, NA, NA, 1,
    "4", NA, "Maternity", NA, NA, NA, 1,
    # Psychiatry
    "5", "04B", NA, NA, "G4", NA, 1, # wrong
    "6", "04B", NA, NA, "F1", NA, 1, # right
    # Acute elective
    "7", "01B", "Elective", NA, NA, NA, 1, # right
    "8", "01B", NA, "D", NA, NA, 1, # right
    "9", "01B", "Elective", "D", "AB", NA, 1, # wrong
    # Acute emergency
    "10", "01B", "Non-Elective", NA, NA, NA, 1, # right
    "11", "01B", "Non-Elective", NA, "AB", NA, 1, # wrong
    # Outpatient
    "12", "00B", NA, NA, "AB", NA, 2,
    # Care Home
    "13", "CH", NA, NA, NA, NA, 1,
    # Hospital Elective
    "14", "01B", "Elective", NA, NA, NA, 1, # right
    "15", "AE2", "Elective", NA, NA, NA, 1, # wrong
    # Hospital emergency
    "16", "50B", "Non-Elective", NA, NA, NA, 1, # right
    "17", "CH", "Non-Elective", NA, NA, NA, 1, # wrong
    # Prescribing
    "18", "PIS", NA, NA, NA, NA, 1,
    # A&E
    "19", "OoH", NA, NA, NA, NA, 1,
    # Community
    "20", "DN", NA, NA, NA, NA, 1,
    # Operation flag
    "21", "00B", NA, NA, NA, "V092", 1
  )

  # Geriatric
  expect_equal(
    calculate_geriatric_cost(dummy_data$recid, dummy_data$spec, dummy_data$cost_total_net),
    c(1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0)
  )

  # Maternity
  expect_equal(
    calculate_maternity_cost(dummy_data$recid, dummy_data$cij_pattype, dummy_data$cost_total_net),
    c(0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  # Psychiatry
  expect_equal(
    calculate_psychiatry_cost(dummy_data$recid, dummy_data$spec, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  # Acute elective
  expect_equal(
    calculate_acute_elective_cost(dummy_data$recid, dummy_data$cij_pattype, dummy_data$cij_ipdc,
                                  dummy_data$spec, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
  )

  # Acute Emergency
  expect_equal(
    calculate_acute_emergency_cost(dummy_data$recid, dummy_data$cij_pattype,
                                  dummy_data$spec, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  # Create geriatric costs for outpatient costs
  dummy_data_op <- dummy_data %>%
    dplyr::mutate(geriatric_cost = calculate_geriatric_cost(recid, spec, cost_total_net))

  # Outpatient
  expect_equal(
    calculate_outpatient_costs(dummy_data_op$recid,
                               dummy_data_op$cost_total_net,
                               dummy_data_op$geriatric_cost)[[1]],
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
  )

  # Care Home
  expect_equal(
    calculate_care_home_cost(dummy_data$recid, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0)
  )

  # Hospital Elective
  expect_equal(
    calculate_hospital_elective_cost(dummy_data$recid, dummy_data$cij_pattype,
                                     dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
  )

  # Hospital Emergency
  expect_equal(
    calculate_hospital_emergency_cost(dummy_data$recid, dummy_data$cij_pattype,
                                     dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
  )

  # Prescribing
  expect_equal(
    calculate_prescribing_cost(dummy_data$recid, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
  )

  # A&E
  expect_equal(
    calculate_ae2_cost(dummy_data$recid, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0)
  )

  # Community
  expect_equal(
    calculate_community_health_cost(dummy_data$recid, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
  )

  # Operation flag
  expect_equal(
    add_operation_flag(dummy_data$op1a),
    c(F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, T)
  )
})
