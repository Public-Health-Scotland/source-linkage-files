test_that("is_date_in_fyyear errors as expected", {
  expect_error(
    is_date_in_fyyear("2017", Sys.time()),
    "The `year` has been entered in the wrong format"
  )

  expect_error(
    is_date_in_fyyear("1718", "2017-04-01"),
    "must be a `Date` or `POSIXct` vector"
  )

  expect_error(
    is_date_in_fyyear("1718", as.Date("2017-04-01"), "2017-04-01"),
    "must be a `Date` or `POSIXct` vector"
  )

  expect_error(
    is_date_in_fyyear("1718", as.Date("2018-04-01"), as.Date("2017-01-01")),
    "`date_end` must not be earlier than `date`"
  )
})

test_that("is_date_in_fyyear works for a single year", {
  expect_type(is_date_in_fyyear("1718", Sys.time()), "logical")

  expect_true(is_date_in_fyyear("1718", as.Date("2017-04-01")))
  expect_true(is_date_in_fyyear("1718", as.Date("2018-03-31")))

  expect_false(is_date_in_fyyear("1718", as.Date("2017-03-31")))
  expect_false(is_date_in_fyyear("1718", as.Date("2018-04-01")))

  expect_identical(is_date_in_fyyear("1718", lubridate::NA_Date_), NA)

  expect_identical(
    is_date_in_fyyear(
      "1718",
      as.Date(c(
        "2017-03-31",
        "2017-04-01",
        "2018-01-01",
        "2018-03-31",
        "2018-04-01",
        NA
      ))
    ),
    c(FALSE, TRUE, TRUE, TRUE, FALSE, NA)
  )
})

test_that("is_date_in_fyyear works for a year range (interval)", {
  expect_type(is_date_in_fyyear("1718", Sys.Date(), Sys.Date() + 1), "logical")

  # Start before, end before
  expect_false(is_date_in_fyyear("1718", as.Date("2017-01-01"), as.Date("2017-03-31")))
  # Start before, end during
  expect_true(is_date_in_fyyear("1718", as.Date("2017-01-01"), as.Date("2018-01-01")))
  # Start before, end after
  expect_true(is_date_in_fyyear("1718", as.Date("2017-01-01"), as.Date("2019-01-01")))
  # Start before, missing end date
  expect_true(is_date_in_fyyear("1718", as.Date("2017-01-01"), lubridate::NA_Date_))

  # Start during, end during
  expect_true(is_date_in_fyyear("1718", as.Date("2017-04-01"), as.Date("2018-01-01")))
  # Start during, end after
  expect_true(is_date_in_fyyear("1718", as.Date("2017-04-01"), as.Date("2019-01-01")))
  # Start during, missing end date
  expect_true(is_date_in_fyyear("1718", as.Date("2017-04-01"), lubridate::NA_Date_))

  # Start after, end after
  expect_false(is_date_in_fyyear("1718", as.Date("2018-04-01"), as.Date("2019-01-01")))
  # Start after, missing end date
  expect_false(is_date_in_fyyear("1718", as.Date("2018-04-01"), lubridate::NA_Date_))

  expect_identical(
    is_date_in_fyyear(
      "1718",
      as.Date(
        c(
          "2017-01-01",
          "2017-01-01",
          "2017-01-01",
          "2017-01-01",
          "2017-04-01",
          "2017-04-01",
          "2017-04-01",
          "2018-04-01",
          "2018-04-01"
        )
      ),
      as.Date(
        c(
          "2017-03-31",
          "2018-01-01",
          "2019-01-01",
          NA,
          "2018-01-01",
          "2019-01-01",
          NA,
          "2019-01-01",
          NA
        )
      )
    ),
    c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE)
  )
})
