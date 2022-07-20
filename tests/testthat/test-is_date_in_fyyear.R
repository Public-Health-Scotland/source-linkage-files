test_that("is_date_in_fyyear errors as expected", {
  expect_error(
    is_date_in_fyyear("2017", Sys.time()),
    "The year has been entered in the wrong format"
  )

  expect_error(
    is_date_in_fyyear("1718", "2017-04-01"),
    "not a recognized date-time"
  )
})

test_that("is_date_in_fyyear works for a single year", {
  expect_type(is_date_in_fyyear("1718", Sys.time()), "logical")

  expect_true(is_date_in_fyyear("1718", as.Date("2017-04-01")))
  expect_true(is_date_in_fyyear("1718", as.Date("2018-03-31")))

  expect_false(is_date_in_fyyear("1718", as.Date("2017-03-31")))
  expect_false(is_date_in_fyyear("1718", as.Date("2018-04-01")))
})

test_that("is_date_in_fyyear works for a year range (interval)", {
  expect_type(is_date_in_fyyear("1718", Sys.Date(), Sys.Date() + 1), "logical")

  expect_true(is_date_in_fyyear("1718", as.Date("2017-04-01"), as.Date("2018-04-01")))
  expect_true(is_date_in_fyyear("1718", as.Date("2018-03-31"), as.Date("2021-04-01")))

  # Starts before, ends after
  expect_true(is_date_in_fyyear("1718", as.Date("2016-03-31"), as.Date("2019-04-01")))

  expect_false(is_date_in_fyyear("1718", as.Date("2017-01-01"), as.Date("2017-03-31")))
  expect_false(is_date_in_fyyear("1718", as.Date("2018-04-01"), as.Date("2018-12-31")))
})
