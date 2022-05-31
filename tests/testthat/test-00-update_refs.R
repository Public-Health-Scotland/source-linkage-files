test_that("IT extract ref number looks valid", {
  it_ref <- it_extract_ref()

  expect_type(it_ref, "character")
  expect_match(it_ref, "SCTASK\\d{7}")
})

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
