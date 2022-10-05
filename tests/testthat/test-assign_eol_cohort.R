test_that("Fall codes and end_of_life_cohort are assigned correctly", {
  tester <- tibble::tribble(
    ~recid, ~deathdiag1, ~deathdiag2, ~deathdiag3, ~deathdiag4, ~deathdiag5,
    ~deathdiag6, ~deathdiag7, ~deathdiag8, ~deathdiag9, ~deathdiag10, ~deathdiag11,
    # external_cause should be TRUE
    "01B", "V02", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "GLS", "A24", "X86", NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "A&E", "A24", "B12", "Y23", NA, NA, NA, NA, NA, NA, NA, NA,
    # external_cause should be NA
    "04B", "W01", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "02B", "V22", "W18", NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "V67", "W00", NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "X99", "W99", "W12", NA, NA, NA, NA, NA, NA, NA, NA
  )

  assigned_tester <- assign_eol_cohort(tester)

  expect_equal(
    assigned_tester$external_cause,
    c(T, T, T, NA, NA, NA, NA)
  )

  expect_equal(
    assigned_tester$end_of_life_cohort,
    c(F, F, F, F, F, T, T)
  )
})

test_that("Error throws as expected", {
  error_tester <- tibble::tribble(~recid, ~deathdiag1, ~something_wrong)

  expect_error(assign_eol_cohort(error_tester), regexp = "Variables .+ are required, but are missing from `data`")
})
