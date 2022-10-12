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

test_that("Errors throw as expected", {
  expect_error(assign_cohort_names(tibble::tribble(
    ~psychiatry_cost, ~maternity_cost, ~geriatric_cost,
    ~elective_inpatient_cost, ~limited_daycases_cost,
    ~routine_daycase_cost, ~single_emergency_cost,
    ~multiple_emergency_cost, ~prescribing_cost, ~silly
  )),
  regexp = "Variables .+ are required, but are missing from `data`"
  )
})
