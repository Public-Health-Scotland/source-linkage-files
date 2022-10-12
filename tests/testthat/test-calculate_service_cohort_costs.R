test_that("Costs are calculated correctly", {

  dummy_data <- tibble::tribble(
    ~elective_inpatient_cohort, ~limited_daycases_cohort, ~routine_daycase_cohort,
    ~single_emergency_cohort, ~multiple_emergency_cohort, ~community_care_cohort,
    ~acute_elective_cost, ~acute_emergency_cost, ~community_health_cost, ~cost_total_net,
    T, F, F, F, F, F, 10, 0, 0, NA,
    F, T, F, F, F, F, 10, 0, 0, NA,
    F, F, T, F, F, F, 10, 0, 0, NA,
    F, F, F, T, F, F, 0, 10, 0, NA,
    F, F, F, F, T, F, 0, 10, 0, NA,
    F, F, F, F, F, T, 0, 0, 10, NA,
    T, T, T, T, T, T, 10, 20, 30, NA
  )

  test_output <- calculate_service_cohort_costs(dummy_data)

  # Elective
  expect_equal(test_output$elective_inpatient_cost,
               c(10, 0, 0, 0, 0, 0, 10))
  # Limited daycases
  expect_equal(test_output$limited_daycases_cost,
               c(0, 10, 0, 0, 0, 0, 10))
  # Routine daycases
  expect_equal(test_output$routine_daycase_cost,
               c(0, 0, 10, 0, 0, 0, 10))
  # Single emergency
  expect_equal(test_output$single_emergency_cost,
               c(0, 0, 0, 10, 0, 0, 20))
  # Multiple emergency
  expect_equal(test_output$multiple_emergency_cost,
               c(0, 0, 0, 0, 10, 0, 20))
  # Community care
  expect_equal(test_output$community_care_cost,
               c(0, 0, 0, 0, 0, 10, 30))
  # Residential care (not used)
  expect_equal(test_output$residential_care_cost,
               c(0, 0, 0, 0, 0, 0, 0))
  # Test that cost_total_net has been set to zero
  expect_equal(test_output$cost_total_net,
               c(0, 0, 0, 0, 0, 0, 0))
})

test_that("Errors are as expected", {

  expect_error(
    calculate_service_cohort_costs(
      tibble::tribble(~recid, ~nonsense, ~limited_daycases_cohort)),
    regexp = "Variables .+ are required, but are missing from `data`")

})
