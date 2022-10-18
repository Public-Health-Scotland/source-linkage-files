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

  test_output <- assign_service_cohorts(dummy_data)

  # Psychiatry
  expect_equal(
    test_output$psychiatry_cohort,
    c(
      TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Maternity
  expect_equal(
    test_output$maternity_cohort,
    c(
      FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Geriatric
  expect_equal(
    test_output$geriatric_cohort,
    c(
      FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Elective inpatient
  expect_equal(
    test_output$elective_inpatient_cohort,
    c(
      FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Limited daycases
  expect_equal(
    test_output$limited_daycases_cohort,
    c(
      TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE,
      TRUE, TRUE, TRUE, FALSE, FALSE
    )
  )
  # Routine daycases
  expect_equal(
    test_output$routine_daycase_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    )
  )
  # Single emergency
  expect_equal(
    test_output$single_emergency_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    )
  )
  # Multiple emergency
  expect_equal(
    test_output$multiple_emergency_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Prescribing
  expect_equal(
    test_output$prescribing_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,
      FALSE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Outpatients
  expect_equal(
    test_output$outpatient_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      TRUE, FALSE, FALSE, FALSE, FALSE, TRUE
    )
  )
  # Community
  expect_equal(
    test_output$community_care_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, TRUE, TRUE, FALSE, FALSE, TRUE
    )
  )
  # A&E
  expect_equal(
    test_output$ae2_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, TRUE, FALSE, TRUE
    )
  )
  # Other
  expect_equal(
    test_output$other_cohort,
    c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, TRUE, FALSE
    )
  )
})

test_that("Errors are handled correctly", {
  expect_error(assign_service_cohorts(tibble::tribble(~recid, ~sily, ~fake)),
    regexp = "Variables .+ are required, but are missing from `data`"
  )
})
