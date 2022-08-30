test_that("start_fy_quarter works", {
  expect_equal(start_fy_quarter("2017Q1"), as.Date("2017-04-01"))
  expect_equal(start_fy_quarter("2010Q1"), as.Date("2010-04-01"))
  expect_equal(start_fy_quarter("2020Q1"), as.Date("2020-04-01"))
  expect_equal(start_fy_quarter("2019Q2"), as.Date("2019-07-01"))
  expect_equal(start_fy_quarter("2019Q3"), as.Date("2019-10-01"))
  expect_equal(start_fy_quarter("2019Q4"), as.Date("2020-01-01"))

  expect_equal(start_fy_quarter(c(
    "2017Q1",
    "2010Q1",
    "2020Q1",
    "2019Q2",
    "2019Q3",
    "2019Q4"
  )), as.Date(c(
    "2017-04-01",
    "2010-04-01",
    "2020-04-01",
    "2019-07-01",
    "2019-10-01",
    "2020-01-01"
  )))
})

test_that("end_fy_quarter works", {
  expect_equal(end_fy_quarter("2017Q1"), as.Date("2017-06-30"))
  expect_equal(end_fy_quarter("2010Q1"), as.Date("2010-06-30"))
  expect_equal(end_fy_quarter("2020Q1"), as.Date("2020-06-30"))
  expect_equal(end_fy_quarter("2019Q2"), as.Date("2019-09-30"))
  expect_equal(end_fy_quarter("2019Q3"), as.Date("2019-12-31"))
  expect_equal(end_fy_quarter("2019Q4"), as.Date("2020-03-31"))

  expect_equal(end_fy_quarter(c(
    "2017Q1",
    "2010Q1",
    "2020Q1",
    "2019Q2",
    "2019Q3",
    "2019Q4"
  )), as.Date(c(
    "2017-06-30",
    "2010-06-30",
    "2020-06-30",
    "2019-09-30",
    "2019-12-31",
    "2020-03-31"
  )))
})

test_that("start_next_fy_quarter works", {
  expect_equal(start_next_fy_quarter("2017Q1"), as.Date("2017-07-01"))
  expect_equal(start_next_fy_quarter("2010Q1"), as.Date("2010-07-01"))
  expect_equal(start_next_fy_quarter("2020Q1"), as.Date("2020-07-01"))
  expect_equal(start_next_fy_quarter("2019Q2"), as.Date("2019-10-01"))
  expect_equal(start_next_fy_quarter("2019Q3"), as.Date("2020-01-01"))
  expect_equal(start_next_fy_quarter("2019Q4"), as.Date("2020-04-01"))

  expect_equal(start_next_fy_quarter(c(
    "2017Q1",
    "2010Q1",
    "2020Q1",
    "2019Q2",
    "2019Q3",
    "2019Q4"
  )), as.Date(c(
    "2017-07-01",
    "2010-07-01",
    "2020-07-01",
    "2019-10-01",
    "2020-01-01",
    "2020-04-01"
  )))
})

test_that("end_next_fy_quarter works", {
  expect_equal(end_next_fy_quarter("2017Q1"), as.Date("2017-09-30"))
  expect_equal(end_next_fy_quarter("2010Q1"), as.Date("2010-09-30"))
  expect_equal(end_next_fy_quarter("2020Q1"), as.Date("2020-09-30"))
  expect_equal(end_next_fy_quarter("2019Q2"), as.Date("2019-12-31"))
  expect_equal(end_next_fy_quarter("2019Q3"), as.Date("2020-03-31"))
  expect_equal(end_next_fy_quarter("2019Q4"), as.Date("2020-06-30"))

  expect_equal(end_next_fy_quarter(c(
    "2017Q1",
    "2010Q1",
    "2020Q1",
    "2019Q2",
    "2019Q3",
    "2019Q4"
  )), as.Date(c(
    "2017-09-30",
    "2010-09-30",
    "2020-09-30",
    "2019-12-31",
    "2020-03-31",
    "2020-06-30"
  )))
})

test_that("bad inputs for quarter error properly", {
  # Single NA
  expect_error(start_fy_quarter(NA), "typeof\\(quarter\\) == \"character\" is not TRUE")
  expect_error(end_fy_quarter(NA), "typeof\\(quarter\\) == \"character\" is not TRUE")
  expect_error(start_next_fy_quarter(NA), "typeof\\(quarter\\) == \"character\" is not TRUE")
  expect_error(end_next_fy_quarter(NA), "typeof\\(quarter\\) == \"character\" is not TRUE")

  # All NA
  expect_error(start_fy_quarter(c(NA, NA)), "typeof\\(quarter\\) == \"character\" is not TRUE")
  expect_error(end_fy_quarter(c(NA, NA)), "typeof\\(quarter\\) == \"character\" is not TRUE")
  expect_error(start_next_fy_quarter(c(NA, NA)), "typeof\\(quarter\\) == \"character\" is not TRUE")
  expect_error(end_next_fy_quarter(c(NA, NA)), "typeof\\(quarter\\) == \"character\" is not TRUE")

  # Not all NA
  expect_equal(start_fy_quarter(c("2017Q1", NA)), as.Date(c("2017-04-01", NA)))
  expect_equal(end_fy_quarter(c("2017Q1", NA)), as.Date(c("2017-06-30", NA)))
  expect_equal(start_next_fy_quarter(c("2017Q1", NA)), as.Date(c("2017-07-01", NA)))
  expect_equal(end_next_fy_quarter(c("2017Q1", NA)), as.Date(c("2017-09-30", NA)))

  # Bad quarter format
  expect_error(start_fy_quarter("2017-4"))
  expect_error(end_fy_quarter("2017-4"))
  expect_error(start_next_fy_quarter("2017-4"))
  expect_error(start_fy_quarter(c("2017Q4", "2017-4")))
  expect_error(end_fy_quarter(c("2017Q4", "2017-4")))
  expect_error(start_next_fy_quarter(c("2017Q4", "2017-4")))
  expect_error(end_next_fy_quarter(c("2017Q4", "2017-4")))
})
