test_that("monthly beddays errors properly", {
  expect_error(
    create_monthly_beddays(
      tibble(start_date = Sys.Date(), end_date = "2021-01-01"),
      "2223",
      start_date,
      end_date
    ),
    "`discharge_date` must be a `Date` or `POSIXct` vector"
  )

  expect_error(
    create_monthly_beddays(
      tibble(start_date = "2021-01-01", end_date = Sys.Date()),
      "2223",
      start_date,
      end_date
    ),
    "`admission_date` must be a `Date` or `POSIXct` vector"
  )

  expect_error(
    create_monthly_beddays(
      tibble(start_date = Sys.Date() + 1, end_date = Sys.Date()),
      "2223",
      start_date,
      end_date
    ),
    "`discharge_date` must not be earlier than `admission_date`"
  )

  input_data <- tibble(
    adm_date = as.Date(c(
      "2020-01-02",
      "2020-04-05",
      "2020-09-20",
      "2017-01-01",
      "2021-03-01",
      "2019-01-01",
      "2020-01-01",
      "2021-01-01",
      "2022-01-01",
      "2022-04-01"
    )),
    dis_date = as.Date(c(
      "2021-01-01",
      "2021-02-01",
      "2020-12-31",
      "2022-12-01",
      "2021-03-05",
      NA,
      NA,
      NA,
      "2020-01-01",
      "2022-03-31"
    ))
  )

  expect_snapshot_error(
    create_monthly_beddays(input_data, "2122", adm_date, dis_date)
  )
})


test_that("monthly beddays work as expected", {
  input_data <- tibble(
    adm_date = as.Date(c(
      "2020-01-02",
      "2020-04-05",
      "2020-09-20",
      "2017-01-01",
      "2021-03-01",
      "2019-01-01",
      "2020-01-01",
      "2021-01-01"
    )),
    dis_date = as.Date(c(
      "2021-01-01",
      "2021-02-01",
      "2020-12-31",
      "2022-12-01",
      "2021-03-05",
      NA,
      NA,
      NA
    ))
  )

  expect_snapshot(as.data.frame(
    create_monthly_beddays(input_data, year = "1819", adm_date, dis_date)
  ))
  expect_snapshot(as.data.frame(
    create_monthly_beddays(input_data, year = "1920", adm_date, dis_date)
  ))
  expect_snapshot(as.data.frame(
    create_monthly_beddays(input_data, year = "2021", adm_date, dis_date)
  ))
})
