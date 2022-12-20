test_that("Can return start FY date", {
  expect_equal(start_fy("1718", format = "fyyear"), as.Date("2017-04-01"))
  expect_equal(start_fy("1920"), as.Date("2019-04-01"))
  expect_equal(start_fy("2021"), as.Date("2020-04-01"))

  expect_equal(start_fy("2020", format = "alternate"), as.Date("2020-04-01"))
})



test_that("Can return end FY date", {
  expect_equal(end_fy("1718", format = "fyyear"), as.Date("2018-03-31"))
  expect_equal(end_fy("1920"), as.Date("2020-03-31"))
  expect_equal(end_fy("2021"), as.Date("2021-03-31"))

  expect_equal(end_fy("2021", format = "alternate"), as.Date("2022-03-31"))
})



test_that("Can return midpoint FY date", {
  expect_equal(midpoint_fy("1718"), as.Date("2017-09-30"))
  expect_equal(midpoint_fy("1920"), as.Date("2019-09-30"))
  expect_equal(midpoint_fy("2021"), as.Date("2020-09-30"))

  expect_equal(midpoint_fy("2021", format = "alternate"), as.Date("2021-09-30"))
})

test_that("FY interval is correct", {
  expect_s4_class(fy_interval("1718"), "Interval")

  expect_equal(
    fy_interval("1718"),
    lubridate::interval(
      as.Date("2017-04-01"),
      as.Date("2018-03-31")
    )
  )
})

test_that("FY interval is correct", {
  expect_s4_class(fy_interval("1718"), "Interval")

  expect_equal(
    fy_interval("1718"),
    lubridate::interval(
      as.Date("2017-04-01"),
      as.Date("2018-03-31")
    )
  )
})
