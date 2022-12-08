test_that("Mental Health demographic cohort functions work", {
  mh_test <- tibble::tribble(
    ~recid, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6,
    "04B", NA, NA, NA, NA, NA, NA,
    "02B", "F2", NA, NA, NA, NA, NA,
    "AE2", NA, NA, NA, NA, "F067", NA,
    "CH", "F2", NA, NA, NA, NA, NA
  )

  expect_equal(
    mh_test %>%
      dplyr::mutate(
        mh = assign_d_cohort_mh(recid, diag1, diag2, diag3, diag4, diag5, diag6)
      ) %>%
      dplyr::pull(mh),
    c(TRUE, TRUE, TRUE, FALSE)
  )
})

test_that("Fraility demographic cohort functions work", {
  frail_test <- tibble::tribble(
    ~recid, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6, ~spec, ~sigfac,
    "01B", "W0", NA, NA, NA, NA, NA, NA, NA,
    "04B", "A1", "A2", "I64", NA, NA, NA, NA, NA,
    "AE2", NA, NA, NA, NA, NA, NA, "AB", NA,
    "CH", NA, NA, NA, NA, NA, NA, NA, "1E",
    "GLS", NA, NA, NA, NA, NA, NA, NA, NA
  )

  expect_equal(
    frail_test %>%
      dplyr::mutate(
        frail =
          assign_d_cohort_frailty(recid, diag1, diag2, diag3, diag4, diag5, diag6, spec, sigfac)
      ) %>%
      dplyr::pull(frail),
    c(TRUE, TRUE, TRUE, FALSE, TRUE)
  )
})


test_that("High Complex conditions demographic cohort functions work", {
  high_cc_test <- tibble::tribble(
    ~dementia, ~hefailure, ~refailure, ~liver, ~cancer, ~spec,
    TRUE, TRUE, FALSE, FALSE, FALSE, NA,
    FALSE, FALSE, TRUE, FALSE, FALSE, NA,
    NA, NA, NA, TRUE, NA, NA,
    FALSE, FALSE, FALSE, FALSE, FALSE, "G5"
  )

  expect_equal(
    high_cc_test %>%
      dplyr::mutate(
        high_cc =
          assign_d_cohort_high_cc(dementia, hefailure, refailure, liver, cancer, spec)
      ) %>%
      dplyr::pull(high_cc),
    c(TRUE, TRUE, TRUE, TRUE)
  )
})

test_that("Medium complex conditions demographic cohort functions work", {
  medium_cc_test <- tibble::tribble(
    ~cvd, ~copd, ~chd, ~parkinsons, ~ms,
    TRUE, FALSE, FALSE, FALSE, FALSE,
    FALSE, FALSE, TRUE, TRUE, FALSE,
    NA, NA, NA, NA, TRUE,
    FALSE, FALSE, NA, NA, NA
  )

  expect_equal(
    medium_cc_test %>%
      dplyr::mutate(
        medium_cc =
          assign_d_cohort_medium_cc(cvd, copd, chd, parkinsons, ms)
      ) %>%
      dplyr::pull(medium_cc),
    c(TRUE, TRUE, TRUE, FALSE)
  )
})


test_that("Low Complex conditions demographic cohort functions work", {
  low_cc_test <- tibble::tribble(
    ~epilepsy, ~asthma, ~arth, ~diabetes, ~atrialfib,
    TRUE, FALSE, FALSE, FALSE, FALSE,
    FALSE, FALSE, TRUE, TRUE, FALSE,
    NA, NA, NA, NA, TRUE,
    FALSE, FALSE, NA, NA, NA
  )

  expect_equal(
    low_cc_test %>%
      dplyr::mutate(
        low_cc =
          assign_d_cohort_low_cc(epilepsy, asthma, arth, diabetes, atrialfib)
      ) %>%
      dplyr::pull(low_cc),
    c(TRUE, TRUE, TRUE, FALSE)
  )
})

test_that("Community Living demographic cohort functions work", {
  comm_living_test <- tibble::tribble(
    ~epilepsy, ~asthma, ~arth, ~diabetes, ~atrialfib,
    TRUE, FALSE, FALSE, FALSE, FALSE,
    FALSE, FALSE, TRUE, TRUE, FALSE,
    NA, NA, NA, NA, TRUE,
    FALSE, FALSE, NA, NA, NA
  )

  expect_equal(
    comm_living_test %>%
      dplyr::mutate(
        comm_living =
          assign_d_cohort_comm_living()
      ) %>%
      dplyr::pull(comm_living),
    c(FALSE, FALSE, FALSE, FALSE)
  )
})

test_that("Adult  major cond demographic cohort functions work", {
  adult_major_test <- tibble::tribble(
    ~recid, ~cost_total_net, ~age,
    "01B", 0, 20,
    "PIS", 1000, 72,
    "PIS", 499, 54,
    "01B", 600, 4
  )

  expect_equal(
    adult_major_test %>%
      dplyr::mutate(
        adult_major =
          assign_d_cohort_adult_major(recid, age, cost_total_net)
      ) %>%
      dplyr::pull(adult_major),
    c(TRUE, TRUE, FALSE, FALSE)
  )
})

test_that("Child major demographic cohort functions work", {
  child_major_test <- tibble::tribble(
    ~recid, ~cost_total_net, ~age,
    "01B", 0, 4,
    "PIS", 1000, 17,
    "PIS", 499, 16,
    "01B", 600, 22
  )

  expect_equal(
    child_major_test %>%
      dplyr::mutate(
        child_major =
          assign_d_cohort_child_major(recid, age, cost_total_net)
      ) %>%
      dplyr::pull(child_major),
    c(TRUE, TRUE, FALSE, FALSE)
  )
})

test_that("End of Life demographic cohort functions work", {
  eol_test <- tibble::tribble(
    ~recid, ~deathdiag1, ~deathdiag2, ~deathdiag3, ~deathdiag4, ~deathdiag5,
    ~deathdiag6, ~deathdiag7, ~deathdiag8, ~deathdiag9, ~deathdiag10,
    ~deathdiag11,
    "NRS", "V01", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "Y84", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "V45", "W00", NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "NRS", "X00", "X01", "W19", NA, NA, NA, NA, NA, NA, NA, NA
  )

  expect_equal(
    eol_test %>%
      dplyr::mutate(
        end_of_life =
          assign_d_cohort_eol(
            recid, deathdiag1, deathdiag2, deathdiag3, deathdiag4, deathdiag5,
            deathdiag6, deathdiag7, deathdiag8, deathdiag9, deathdiag10,
            deathdiag11
          )
      ) %>%
      dplyr::pull(end_of_life),
    c(FALSE, FALSE, TRUE, TRUE)
  )
})
