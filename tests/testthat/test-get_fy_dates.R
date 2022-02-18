library(testthat)

test_that("Can return start FY date", {
  year <- c(
    1718,
    1920,
    2021
  )

  expect_equal(
    start_fy(year),
    as.Date(c(
      "2017-04-01",
      "2019-04-01",
      "2020-04-01"
    ))
  )
})



test_that("Can return end FY date", {
  year <- c(
    1718,
    1920,
    2021
  )

  expect_equal(
    end_fy(year),
    as.Date(c(
      "2018-03-31",
      "2020-03-31",
      "2021-03-31"
    ))
  )
})



test_that("Can return midpoint FY date", {
  year <- c(
    1718,
    1920, # leapyear
    2021
  )

  expect_equal(
    midpoint_fy(year),
    as.Date(c(
      "2017-09-30",
      "2019-09-30",
      "2020-09-30"
    ))
  )
})
