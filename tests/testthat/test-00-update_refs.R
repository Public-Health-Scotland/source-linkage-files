test_that("Latest Update string looks valid", {
  latest_update_string <- latest_update()

  expect_type(latest_update_string, "character")
  expect_match(latest_update_string, "[A-Z][a-z]{2}_20[0-9]{2}")
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
