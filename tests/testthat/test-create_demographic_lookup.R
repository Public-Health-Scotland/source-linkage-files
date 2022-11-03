test_that("Different cohort functions work", {
  # Mental Health
  mh_test <- tibble::tribble(
    ~recid, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6,
    "04B", NA, NA, NA, NA, NA, NA,
    "02B", "F2", NA, NA, NA, NA, NA,
    "AE2", NA, NA, NA, NA, "F067", NA,
    "CH", "F2", NA, NA, NA, NA, NA
  )

  expect_equal(
    (mh_test %>% mutate(mh = assign_mh_cohort(recid, diag1, diag2, diag3, diag4, diag5, diag6)))$mh,
    c(T, T, T, F)
  )

  # Frailty
  frail_test <- tibble::tribble(
    ~recid, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6, ~spec, ~sigfac,
    "01B", "W0", NA, NA, NA, NA, NA, NA, NA,
    "04B", "A1", "A2", "I64", NA, NA, NA, NA, NA,
    "AE2", NA, NA, NA, NA, NA, NA, "AB", NA,
    "CH", NA, NA, NA, NA, NA, NA, NA, "1E",
    "GLS", NA, NA, NA, NA, NA, NA, NA, NA
  )

  expect_equal(
    (frail_test %>%
      mutate(
        frail =
          assign_frailty_cohort(recid, diag1, diag2, diag3, diag4, diag5, diag6, spec, sigfac)
      ))$frail,
    c(T, T, T, F, T)
  )

  # High CC
  high_cc_test <- tibble::tribble(
    ~dementia, ~hefailure, ~refailure, ~liver, ~cancer, ~spec,
    T, T, F, F, F, NA,
    F, F, T, F, F, NA,
    NA, NA, NA, T, NA, NA,
    F, F, F, F, F, "G5"
  )

  expect_equal(
    (high_cc_test %>%
      mutate(
        high_cc =
          assign_high_cc_cohort(dementia, hefailure, refailure, liver, cancer, spec)
      ))$high_cc,
    c(T, T, T, T)
  )

  # Medium CC
  medium_cc_test <- tibble::tribble(
    ~cvd, ~copd, ~chd, ~parkinsons, ~ms,
    T, F, F, F, F,
    F, F, T, T, F,
    NA, NA, NA, NA, T,
    F, F, NA, NA, NA
  )

  expect_equal(
    (medium_cc_test %>%
      mutate(
        medium_cc =
          assign_medium_cc_cohort(cvd, copd, chd, parkinsons, ms)
      ))$medium_cc,
    c(T, T, T, F)
  )

  # Low CC
  low_cc_test <- tibble::tribble(
    ~epilepsy, ~asthma, ~arth, ~diabetes, ~atrialfib,
    T, F, F, F, F,
    F, F, T, T, F,
    NA, NA, NA, NA, T,
    F, F, NA, NA, NA
  )

  expect_equal(
    (low_cc_test %>%
      mutate(
        low_cc =
          assign_low_cc_cohort(epilepsy, asthma, arth, diabetes, atrialfib)
      ))$low_cc,
    c(T, T, T, F)
  )

  # Comm living
  expect_equal(
    (low_cc_test %>%
      mutate(
        comm_living =
          assign_comm_living_cohort()
      ))$comm_living,
    c(F, F, F, F)
  )

  # Adult and Child Major
  adult_major_test <- tibble::tribble(
    ~recid, ~cost_total_net, ~age,
    "01B", 0, 20,
    "PIS", 1000, 72,
    "PIS", 499, 54,
    "01B", 600, 4
  )

  expect_equal(
    (adult_major_test %>%
      mutate(
        adult_major =
          assign_adult_major_condition_cohort(recid, age, cost_total_net)
      ))$adult_major,
    c(T, T, F, F)
  )

  child_major_test <- tibble::tribble(
    ~recid, ~cost_total_net, ~age,
    "01B", 0, 4,
    "PIS", 1000, 17,
    "PIS", 499, 16,
    "01B", 600, 22
  )

  expect_equal(
    (child_major_test %>%
      mutate(
        child_major =
          assign_child_major_condition_cohort(recid, age, cost_total_net)
      ))$child_major,
    c(T, T, F, F)
  )

  # End of life
  eol_test <- tibble::tribble(
    ~recid, ~deathdiag1, ~deathdiag2, ~deathdiag3, ~deathdiag4, ~deathdiag5,
    ~deathdiag6, ~deathdiag7, ~deathdiag8, ~deathdiag9, ~deathdiag10,
    ~deathdiag11,
    "NRS", "V01", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "Y84", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "V45", "W00", NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "X00", "X01", "W19", NA, NA, NA, NA, NA, NA, NA, NA
  )

  test2 <- test %>% dplyr::mutate(
    end_of_life =
      assign_eol_cohort(
        recid, deathdiag1, deathdiag2, deathdiag3, deathdiag4, deathdiag5,
        deathdiag6, deathdiag7, deathdiag8, deathdiag9, deathdiag10,
        deathdiag11
      )
  )
})
