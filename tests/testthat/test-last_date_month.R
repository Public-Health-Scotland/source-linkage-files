test_that("last_date_month handles types correctly", {
  expect_s3_class(last_date_month(Sys.Date()), "Date")
  expect_s3_class(last_date_month(lubridate::today()), "Date")

  expect_error(last_date_month("2000-01-01"))
})

test_that("last_date_month is correct", {
  dates <- as.Date(
    c(
      "2020-01-01",
      "2020-01-30",
      "2020-02-01",
      "2020-02-28",
      "2020-02-29",
      "2022-02-01",
      "2022-02-28",
      "2022-02-29"
    )
  )

  expect_equal(
    last_date_month(dates),
    as.Date(
      c(
        "2020-01-31",
        "2020-01-31",
        "2020-02-29",
        "2020-02-29",
        "2020-02-29",
        "2022-02-28",
        "2022-02-28",
        NA
      )
    )
  )
})
