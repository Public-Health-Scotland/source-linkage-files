test_that("Latest Update string looks valid", {
  latest_update_string <- latest_update()

  expect_type(latest_update_string, "character")
  expect_match(latest_update_string, "[A-Z][a-z]{2}_20[0-9]{2}")
})

test_that("Previous Update string looks valid", {
  previous_update_string <- previous_update()

  expect_type(previous_update_string, "character")
  expect_match(previous_update_string, "[A-Z][a-z]{2}_20[0-9]{2}")
})

test_that("Previous Update works for different month values", {
  expect_equal(previous_update(0), latest_update())

  latest_update_month <- lubridate::month(
    lubridate::my(latest_update()),
    label = TRUE,
    abbr = TRUE
  )

  previous_update_month <- lubridate::month(
    lubridate::my(previous_update()),
    label = TRUE,
    abbr = TRUE
  ) %>%
    as.character()

  expected_previous_update_month <- dplyr::case_match(
    latest_update_month,
    "Apr" ~ "Dec",
    "Jul" ~ "Apr",
    "Sep" ~ "Jul",
    "Dec" ~ "Sep",
    # Don't fail on non-standard update months
    .default = previous_update_month
  )

  expect_equal(expected_previous_update_month, previous_update_month)
})

test_that("Previous Update override works", {
  expect_equal(previous_update(override = "May_2023"), "May_2023")
  expect_equal(previous_update(override = "XYZ_1234"), "XYZ_1234")
})

test_that("Delayed Discharge period string looks valid", {
  dd_period_string <- get_dd_period()

  expect_type(dd_period_string, "character")
  expect_match(dd_period_string, "Jul16_[A-Z][a-z]{2}[0-9]{2}")
})

test_that("Latest Cost Year string looks valid", {
  latest_cost_year_string <- latest_cost_year()

  expect_type(latest_cost_year_string, "character")
  expect_match(latest_cost_year_string, "[0-9]{4}")
  expect_equal(latest_cost_year_string, check_year_format("2223"))
})
