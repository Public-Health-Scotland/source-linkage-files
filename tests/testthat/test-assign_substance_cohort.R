test_that("Substance cohort is assigned correctly", {
  tester <- tibble::tribble(
    ~recid, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6,
    # Alcohol
    "01B", "F10", NA, NA, NA, NA, NA,
    "GLS", "A24", NA, NA, "X45", NA, NA,
    # Drug
    "50B", "A24", "T510", NA, NA, NA, NA,
    "AE2", NA, NA, NA, "Z721", NA, NA,
    # F
    "01B", NA, NA, NA, NA, NA, NA,
    "GLS", NA, NA, "T512", NA, NA, NA,
    # F11
    "01B", "F11", NA, NA, NA, NA, NA,
    # F13
    "04B", "A24", "F13", NA, NA, NA, NA,
    # T402, T404
    "01B", NA, NA, NA, "T402", NA, NA,
    "04B", NA, NA, "T404", NA, NA, NA,
    # T424
    "01B", NA, "T424", NA, NA, NA, NA,
    # F11 and T202/404
    "01B", "F11", "T402", NA, NA, NA, NA,
    "04B", NA, NA, "F11", NA, "T404", NA,
    "01B", "T402", NA, NA, NA, "F11", NA,
    # F13 and T424
    "04B", "F13", "T424", NA, NA, NA, NA
  )

  assigned_tester <- assign_substance_cohort(tester)

  # Test substance_cohort variable
  expect_equal(assigned_tester$substance_cohort,
               c(T, T, T, T, F, F, F, F, F, F, F, F, F, F, F))

  # Test f11 variable
  expect_equal(assigned_tester$f11,
               c(F, F, F, F, F, F, T, F, F, F, F, T, T, T, F))

  # Test f13 variable
  expect_equal(assigned_tester$f13,
               c(F, F, F, F, F, F, F, T, F, F, F, F, F, F, T))

  # Test t402_t404 variable
  expect_equal(assigned_tester$t402_t404,
               c(F, F, F, F, F, F, F, F, T, T, F, T, T, T, F))

  # Test t424 variable
  expect_equal(assigned_tester$t424,
               c(F, F, F, F, F, F, F, F, F, F, T, F, F, F, T))
})

test_that("Error throws as expected", {

  error_tester <- tibble::tribble(~recid, ~diag1, ~something_silly, ~diag4)

  expect_error(assign_substance_cohort(error_tester), regexp = "Variables .+ are required, but are missing from `data`")

})
