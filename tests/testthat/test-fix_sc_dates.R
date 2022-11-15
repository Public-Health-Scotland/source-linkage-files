test_that("fix_sc_start_dates works for various cases", {
  # Case where start date is missing
  # Replace with start of fy year
  expect_equal(
    fix_sc_start_dates(
      as.Date(c(NA, NA, NA, NA)),
      c("2018Q1", "2018Q2", "2018Q3", "2018Q4")
    ),
    as.Date(c("2018-04-01", "2018-04-01", "2018-04-01", "2018-04-01"))
  )

  # Case where start date is present
  # Should not replace start date
  expect_equal(
    fix_sc_start_dates(
      as.Date(c("2019-04-01", "2019-07-01", "2019-10-01", "2020-01-01")),
      c("2019Q1", "2019Q2", "2019Q3", "2019Q4")
    ),
    as.Date(c("2019-04-01", "2019-07-01", "2019-10-01", "2020-01-01"))
  )

  # Expect an error when parameters return NA
  expect_error(fix_sc_start_dates(NA, NA))
})


test_that("fix_sc_end_dates works for various cases", {
  # Case where end date is earlier than start date
  # Replace with end of fy year
  expect_equal(
    fix_sc_end_dates(
      as.Date(c("2018-04-30", "2019-05-30", "2020-06-30", "2021-07-30")),
      as.Date(c("2018-04-20", "2019-05-20", "2020-06-20", "2021-07-20")),
      c("2018Q1", "2019Q1", "2020Q1", "2021Q2")
    ),
    as.Date(c("2019-03-31", "2020-03-31", "2021-03-31", "2022-03-31"))
  )

  # Case where end date is after start date
  # Do not replace
  expect_equal(
    fix_sc_end_dates(
      as.Date(c("2018-04-20", "2019-05-20", "2020-06-20", "2021-07-20")),
      as.Date(c("2018-04-30", "2019-05-30", "2020-06-30", "2021-07-30")),
      c("2018Q1", "2019Q1", "2020Q1", "2021Q2")
    ),
    as.Date(c("2018-04-30", "2019-05-30", "2020-06-30", "2021-07-30"))
  )

  # Expect an error when parameters return NA
  expect_error(fix_sc_end_dates(NA, NA, NA))
})
