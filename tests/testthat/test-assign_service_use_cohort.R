test_that("Service use cohorts are applied correctly", {
  # Create dummy data
  tester <- tibble::tribble(
    ~recid, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6, ~age, ~sigfac, ~spec,
    ~dementia, ~hefailure, ~refailure, ~liver, ~cancer, ~cvd, ~copd, ~chd, ~parkinsons, ~ms,
    ~epilepsy, ~asthma, ~arth, ~diabetes, ~atrialfib, ~cost_total_net,
    # MH True
    "04B", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    "01B", "F21", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    "GLS", "G35", "F067", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    # Frail True
    "GLS", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    "01B", "F00", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    "50B", "A24", "R268", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    "02B", NA, NA, NA, NA, NA, NA, NA, "1E", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    "AE2", NA, NA, NA, NA, NA, NA, NA, NA, "AB", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    # Maternity True
    "02B", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    # High_CC True
    "02B", NA, NA, NA, NA, NA, NA, NA, NA, NA, T, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    "02B", NA, NA, NA, NA, NA, NA, NA, NA, "G5", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    # Medium_CC True
    "GLS", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, T, NA, NA, NA, NA, NA, NA, NA, 0,
    # Low_CC True
    "GLS", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, T, NA, 0,
    # Adult_major True
    "PIS", NA, NA, NA, NA, NA, NA, 65, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 1000,
    "01B", NA, NA, NA, NA, NA, NA, 19, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0,
    # Child_major True
    "PIS", NA, NA, NA, NA, NA, NA, 15, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 3500,
    "01B", NA, NA, NA, NA, NA, NA, 2, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0
  )

  tester_assigned <- assign_service_use_cohort(tester)

  # Mental health
  expect_equal(
    tester_assigned$mh_cohort,
    c(T, T, T, F, F, F, F, F, F, F, F, F, F, F, F, F, F)
  )

  # Frailty
  expect_equal(
    tester_assigned$frail_cohort,
    c(F, F, T, T, T, T, T, T, F, F, F, T, T, F, F, F, F)
  )

  # Maternity
  expect_equal(
    tester_assigned$maternity_cohort,
    c(F, F, F, F, F, F, T, F, T, T, T, F, F, F, F, F, F)
  )

  # High_CC
  expect_equal(
    tester_assigned$high_cc_cohort,
    c(F, F, F, F, F, F, F, F, F, T, T, F, F, F, F, F, F)
  )

  # Medium_CC
  expect_equal(
    tester_assigned$medium_cc_cohort,
    c(F, F, F, F, F, F, F, F, F, F, F, T, F, F, F, F, F)
  )

  # Low_CC
  expect_equal(
    tester_assigned$low_cc_cohort,
    c(F, F, F, F, F, F, F, F, F, F, F, F, T, F, F, F, F)
  )

  # Comm living (should always be F until we add this cohort)
  expect_equal(
    tester_assigned$comm_living_cohort,
    c(F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F)
  )

  # Adult major
  expect_equal(
    tester_assigned$adult_major_cohort,
    c(F, F, F, F, F, F, F, F, F, F, F, F, F, T, T, F, F)
  )

  # Child major
  expect_equal(
    tester_assigned$child_major_cohort,
    c(F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, T, T)
  )
})


test_that("Errors throw as expected", {
  error_table_1 <- tibble::tribble(~recid, ~diag1, ~arth, ~fake_variable)

  expect_error(assign_service_use_cohort(error_table_1), regexp = "Variables .+ are required, but are missing from `data`")
})
