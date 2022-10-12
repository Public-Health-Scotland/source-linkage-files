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

  test_output <- create_service_costs(dummy_data)

  # Geriatric
  expect_equal(
    test_output$geriatric_cost,
    c(1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0)
  )

  # Maternity
  expect_equal(
    test_output$maternity_cost,
    c(0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  # Psychiatry
  expect_equal(
    test_output$psychiatry_cost,
    c(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  # Acute elective
  expect_equal(
    test_output$acute_elective_cost,
    c(0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
  )

  # Acute Emergency
  expect_equal(
    test_output$acute_emergency_cost,
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  # Outpatient
  expect_equal(
    test_output$outpatient_cost,
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
  )

  # Care Home
  expect_equal(
    test_output$care_home_cost,
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0)
  )

  # Hospital Elective
  expect_equal(
    test_output$hospital_elective_cost,
    c(0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
  )

  # Hospital Emergency
  expect_equal(
    test_output$hospital_emergency_cost,
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
  )

  # Prescribing
  expect_equal(
    test_output$prescribing_cost,
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
  )

  # A&E
  expect_equal(
    test_output$ae2_cost,
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0)
  )

  # Community
  expect_equal(
    test_output$community_health_cost,
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
  )

  # Operation flag
  expect_equal(
    test_output$operation_flag,
    c(F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, T)
  )
})

test_that("Errors are handled correctly", {

  error_data <- tibble::tribble(~recid, ~op1a, ~cij_pattype, ~something_silly)

  expect_error(create_service_costs(error_data),
               regexp = "Variables .+ are required, but are missing from `data`")
})
