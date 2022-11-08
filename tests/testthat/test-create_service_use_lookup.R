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
    calculate_acute_elective_cost(
      dummy_data$recid, dummy_data$cij_pattype, dummy_data$cij_ipdc,
      dummy_data$spec, dummy_data$cost_total_net
    ),
    c(0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
  )

  # Acute Emergency
  expect_equal(
    calculate_acute_emergency_cost(
      dummy_data$recid, dummy_data$cij_pattype,
      dummy_data$spec, dummy_data$cost_total_net
    ),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  )

  # Create geriatric costs for outpatient costs
  dummy_data_op <- dummy_data %>%
    dplyr::mutate(geriatric_cost = calculate_geriatric_cost(recid, spec, cost_total_net))

  # Outpatient
  expect_equal(
    calculate_outpatient_costs(
      dummy_data_op$recid,
      dummy_data_op$cost_total_net,
      dummy_data_op$geriatric_cost
    )[[1]],
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
  )

  # Care Home
  expect_equal(
    calculate_care_home_cost(dummy_data$recid, dummy_data$cost_total_net),
    c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0)
  )

  # Hospital Elective
  expect_equal(
    calculate_hospital_elective_cost(
      dummy_data$recid, dummy_data$cij_pattype,
      dummy_data$cost_total_net
    ),
    c(0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
  )

  # Hospital Emergency
  expect_equal(
    calculate_hospital_emergency_cost(
      dummy_data$recid, dummy_data$cij_pattype,
      dummy_data$cost_total_net
    ),
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

  dummy_data <- tibble::tribble(
    ~acute_elective_cost, ~elective_inpatient_cost,
    1, 2,
    100, 51,
    500, 499,
    20, 10
  )

  expect_equal(
    assign_elective_inpatient_flag(dummy_data$acute_elective_cost, dummy_data$elective_inpatient_cost),
    c(T, T, T, F)
  )
})

test_that("Instance flags are assigned correctly", {
  dummy_data <- tibble::tribble(
    ~cij_marker, ~cij_pattype, ~cij_ipdc, ~cost_total_net,
    "01B", "Non-Elective", "D", 1,
    "02B", "Elective", "I", 1,
    "04B", "Non-Elective", "I", 1,
    "OoH", "Elective", "D", 1,
    "AE2", "Elective", "", 1,
    "01B", "", "D", 1,
    "NRS", "", "", 1
  )

  # Emergency
  expect_equal(
    assign_emergency_instances(dummy_data$cij_pattype),
    c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)
  )

  # Elective
  expect_equal(
    assign_elective_instances(dummy_data$cij_pattype, dummy_data$cij_ipdc),
    c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE)
  )

  # Elective inpatient
  expect_equal(
    assign_elective_inpatient_instances(dummy_data$cij_pattype, dummy_data$cij_ipdc),
    c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
  )

  # Elective daycase
  expect_equal(
    assign_elective_daycase_instances(dummy_data$cij_pattype, dummy_data$cij_ipdc),
    c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE)
  )

  # Death flags
  expect_equal(
    assign_death_flag(dummy_data$cij_marker),
    c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
  )
})

test_that("Cohorts are assigned correctly", {
  dummy_data <- tibble::tribble(
    ~psychiatry_cost, ~maternity_cost, ~geriatric_cost, ~elective_inpatient_flag, ~elective_instances,
    ~emergency_instances, ~prescribing_cost, ~outpatient_cost, ~care_home_cost, ~community_health_cost,
    ~ae2_cost,
    10, 0, 0, F, 0, 0, 0, 0, 0, 0, 0,
    0, 10, 0, F, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 10, F, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, T, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, F, 2, 0, 0, 0, 0, 0, 0,
    0, 0, 0, F, 15, 0, 0, 0, 0, 0, 0,
    0, 0, 0, F, 0, 1, 0, 0, 0, 0, 0,
    0, 0, 0, F, 0, 4, 0, 0, 0, 0, 0,
    0, 0, 0, F, 0, 0, 10, 0, 0, 0, 0,
    0, 0, 0, F, 0, 0, 0, 10, 0, 0, 0,
    0, 0, 0, F, 0, 0, 0, 0, 10, 0, 0,
    0, 0, 0, F, 0, 0, 0, 0, 0, 10, 0,
    0, 0, 0, F, 0, 0, 0, 0, 0, 0, 10,
    0, 0, 0, F, 3.5, 0, 0, 0, 0, 0, 0,
    10, 10, 10, T, 10, 10, 10, 10, 10, 10, 10
  )

  # Psychiatry
  expect_equal(
    assign_psychiatry_cohort(dummy_data$psychiatry_cost),
    c(
      TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Maternity
  expect_equal(
    assign_maternity_cohort(dummy_data$maternity_cost),
    c(
      FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Geriatric
  expect_equal(
    assign_geriatric_cohort(dummy_data$geriatric_cost),
    c(
      FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Elective inpatient
  expect_equal(
    assign_elective_inpatient_cohort(dummy_data$elective_inpatient_flag),
    c(
      FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Limited daycases
  expect_equal(
    assign_limited_daycases_cohort(dummy_data$elective_inpatient_flag,
                                   dummy_data$elective_instances),
    c(
      TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE,
      TRUE, TRUE, TRUE, FALSE, FALSE
    )
  )
  # Routine daycases
  expect_equal(
    assign_routine_daycase_cohort(dummy_data$elective_inpatient_flag,
                                   dummy_data$elective_instances),
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    )
  )
  # Single emergency
  expect_equal(
    assign_single_emergency_cohort(dummy_data$emergency_instances),
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    )
  )
  # Multiple emergency
  expect_equal(
    assign_multiple_emergency_cohort(dummy_data$emergency_instances),
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Prescribing
  expect_equal(
    assign_prescribing_cohort(dummy_data$prescribing_cost),
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Outpatients
  expect_equal(
    assign_outpatient_cohort(dummy_data$outpatient_cost),
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      TRUE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Community
  expect_equal(
    assign_community_care_cohort(dummy_data$community_health_cost),
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, TRUE, TRUE, FALSE, FALSE, TRUE
    )
  )
  # A&E
  expect_equal(
    assign_ae2_cohort(dummy_data$ae2_cost),
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, TRUE, FALSE, TRUE
    )
  )
})

test_that("Recalculated costs are calculated correctly", {
  dummy_data <- tibble::tribble(
    ~elective_inpatient_cohort, ~limited_daycases_cohort, ~routine_daycase_cohort,
    ~single_emergency_cohort, ~multiple_emergency_cohort, ~community_care_cohort,
    ~acute_elective_cost, ~acute_emergency_cost, ~community_health_cost, ~cost_total_net,
    T, F, F, F, F, F, 10, 0, 0, 10,
    F, T, F, F, F, F, 10, 0, 0, 10,
    F, F, T, F, F, F, 10, 0, 0, 10,
    F, F, F, T, F, F, 0, 10, 0, 10,
    F, F, F, F, T, F, 0, 10, 0, 10,
    F, F, F, F, F, T, 0, 0, 10, 10,
    T, T, T, T, T, T, 10, 20, 30, 10
  )

  # Elective
  expect_equal(
    calculate_elective_inpatient_cost(dummy_data$elective_inpatient_cohort,
                                      dummy_data$cost_total_net),
    c(10, 0, 0, 0, 0, 0, 10)
  )
  # Limited daycases
  expect_equal(
    calculate_limited_daycases_cost(dummy_data$limited_daycases_cohort,
                                    dummy_data$acute_elective_cost),
    c(0, 10, 0, 0, 0, 0, 10)
  )
  # Routine daycases
  expect_equal(
    calculate_routine_daycase_cost(dummy_data$routine_daycase_cohort,
                                    dummy_data$acute_elective_cost),
    c(0, 0, 10, 0, 0, 0, 10)
  )
  # Single emergency
  expect_equal(
    calculate_single_emergency_cost(dummy_data$single_emergency_cohort,
                                    dummy_data$acute_emergency_cost),
    c(0, 0, 0, 10, 0, 0, 20)
  )
  # Multiple emergency
  expect_equal(
    calculate_multiple_emergency_cost(dummy_data$multiple_emergency_cohort,
                                    dummy_data$acute_emergency_cost),
    c(0, 0, 0, 0, 10, 0, 20)
  )
  # Community care
  expect_equal(
    calculate_community_care_cost(dummy_data$community_care_cohort,
                                  dummy_data$community_health_cost),
    c(0, 0, 0, 0, 0, 10, 30)
  )
  # Residential care (not used)
  expect_equal(
    calculate_residential_care_cost(),
    c(0)
  )
})

test_that("Cohort names are assigned correctly", {
  dummy_data <- tibble::tribble(
    ~psychiatry_cost, ~maternity_cost, ~geriatric_cost,
    ~elective_inpatient_cost, ~limited_daycases_cost,
    ~routine_daycase_cost, ~single_emergency_cost,
    ~multiple_emergency_cost, ~prescribing_cost,
    ~outpatient_cost, ~ae2_cost, ~residential_care_cost,
    # Psychiatry
    12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1,
    # Maternity
    1, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2,
    # Geriatric
    2, 1, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3,
    # Geriatric but psych is higher
    13, 1, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3,
    # Elective inpatient
    3, 2, 1, 12, 11, 10, 9, 8, 7, 6, 5, 4,
    # Limited daycases
    4, 3, 2, 1, 12, 11, 10, 9, 8, 7, 6, 5,
    # Routine daycase
    5, 4, 3, 2, 1, 12, 11, 10, 9, 8, 7, 6,
    # Routine daycase but outpatient is higher
    5, 4, 3, 2, 1, 12, 11, 10, 9, 13, 7, 6,
    # Single Emergency
    6, 5, 4, 3, 2, 1, 12, 11, 10, 9, 8, 7,
    # Multiple emergency
    7, 6, 5, 4, 3, 2, 1, 12, 11, 10, 9, 8,
    # Prescribing
    8, 7, 6, 5, 4, 3, 2, 1, 12, 11, 10, 9,
    # Outpatient
    9, 8, 7, 6, 5, 4, 3, 2, 1, 12, 11, 10,
    # A&E
    10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 12, 11,
    # Residential Care
    11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 12,
    # Unassigned
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    # Unassigned
    12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    # Unassigned
    132.32, 132.32, 132.32, 132.32, 132.32, 132.32, 132.32, 132.32, 132.32, 132.32, 132.32, 132.32
  )

  test_output <- assign_cohort_names(dummy_data)

  expect_equal(
    test_output$service_use_cohort,
    c(
      "Psychiatry", "Maternity", "Geriatric", "Psychiatry", "Elective Inpatient",
      "Limited Daycases", "Routine Daycase", "Outpatients", "Single Emergency",
      "Multiple Emergency", "Prescribing", "Outpatients", "Unscheduled Care",
      "Residential Care", "Unassigned", "Unassigned", "Unassigned"
    )
  )
})

test_that("Errors handled as expected", {
  expect_error(create_service_instances(tibble::tribble(~cij_marker, ~test_bad)),
    regexp = "Variables .+ are required, but are missing from `data`"
  )
})


