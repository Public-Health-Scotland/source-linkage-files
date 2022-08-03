test_that("Can return correct length of stay", {

  ## Single calculations

  # Normal calculation - no sc_qtr supplied
  # if start and end dates are both supplied, calculate length of stay

  # Start before FY, end during FY
  expect_equal(calculate_stay("1920", as.Date("2019/03/31"), as.Date("2019/10/31")), 214)
  # Start during FY, end during FY
  expect_equal(calculate_stay("1920", as.Date("2019/06/30"), as.Date("2019/08/31")), 62)
  # Start before FY, end after FY
  expect_equal(calculate_stay("1920", as.Date("2019/01/01"), as.Date("2020/04/01")), 456)
  # Start during FY, end after FY
  expect_equal(calculate_stay("1920", as.Date("2019/04/01"), as.Date("2020/07/01")), 457)

  # Normal calculation - no sc_qtr supplied
  # if start date supplied but end date missing, use dummy date (end_FY + 1) to calculate length of stay

  # Start before FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/03/31"), as.Date(NA)), 367)
  # Start during FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/06/30"), as.Date(NA)), 276)
  # Start before FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/01/01"), as.Date(NA)), 456)
  # Start during FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/04/01"), as.Date(NA)), 366)


  # SC calculation - sc_qtr supplied
  # if start date supplied but end date missing, use end_qtr to calculate length of stay

  # Start before FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/03/31"), as.Date(NA), "2019Q1"), 92)
  # Start during FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/06/30"), as.Date(NA), "2019Q2"), 93)
  # Start before FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/01/01"), as.Date(NA), "2019Q3"), 365)
  # Start during FY, end missing
  expect_equal(calculate_stay("1920", as.Date("2019/04/01"), as.Date(NA), "2019Q4"), 366)

  # SC calculation - sc_qtr supplied
  # if qtr_end < start_date then set to next qtr to calculate length of stay

  # qtr_end < start_date , end missing
  expect_equal(calculate_stay("1920", as.Date("2019/07/31"), as.Date(NA), "2019Q1"), 62)
  # qtr_end < start_date , end missing
  expect_equal(calculate_stay("1920", as.Date("2019/10/31"), as.Date(NA), "2019Q2"), 62)
  # qtr_end < start_date , end missing
  expect_equal(calculate_stay("1920", as.Date("2020/01/31"), as.Date(NA), "2019Q3"), 61)
  # qtr_end < start_date , end missing
  expect_equal(calculate_stay("1920", as.Date("2020/04/30"), as.Date(NA), "2019Q4"), 62)



  ## Vectors

  # Normal calculation - no sc_qtr supplied
  # if start and end dates are both supplied, calculate length of stay

  # Start before FY, end during FY
  expect_equal(
    calculate_stay(
      "1920",
      as.Date(c(
        "2019/03/31", "2019/06/30",
        "2019/01/01", "2019/04/01"
      )),
      as.Date(c(
        "2019/10/31", "2019/08/31",
        "2020/04/01", "2020/07/01"
      ))
    ),
    c(214, 62, 456, 457)
  )

  # Normal calculation - no sc_qtr supplied
  # if start date supplied but end date missing, use dummy date (end_FY + 1) to calculate length of stay
  expect_equal(
    calculate_stay(
      "1920",
      as.Date(c(
        "2019/03/31", "2019/06/30",
        "2019/01/01", "2019/04/01"
      )),
      as.Date(c(NA, NA, NA, NA))
    ),
    c(367, 276, 456, 366)
  )

  # SC calculation - sc_qtr supplied
  # if start date supplied but end date missing, use end_qtr to calculate length of stay
  expect_equal(
    calculate_stay(
      "1920",
      as.Date(c(
        "2019/03/31", "2019/06/30",
        "2019/01/01", "2019/04/01"
      )),
      as.Date(c(NA, NA, NA, NA)),
      c("2019Q1", "2019Q2", "2019Q3", "2019Q4")
    ),
    c(92, 93, 365, 366)
  )


  # SC calculation - sc_qtr supplied
  # if qtr_end < start_date then set to next qtr to calculate length of stay
  expect_equal(
    calculate_stay(
      "1920",
      as.Date(c(
        "2019/07/31", "2019/10/31",
        "2020/01/31", "2020/04/30"
      )),
      as.Date(c(NA, NA, NA, NA)),
      c("2019Q1", "2019Q2", "2019Q3", "2019Q4")
    ),
    c(62, 62, 61, 62)
  )
})

test_that("calculate stay function works", {
  test_tibble <- tibble(
    start_date = as.Date(c(
      "2019/03/31",
      "2019/06/30",
      "2019/01/01",
      "2019/04/01",
      "2019/03/31",
      "2019/06/30",
      "2019/01/01",
      "2019/04/01",
      "2019/03/31",
      "2019/06/30",
      "2019/01/01",
      "2019/04/01",
      "2019/07/31",
      "2019/10/31",
      "2020/01/31",
      "2020/04/30"
    )),
    end_date = as.Date(c(
      "2019/10/31",
      "2019/08/31",
      "2020/04/01",
      "2020/07/01",
      NA,
      NA,
      NA,
      NA,
      NA,
      NA,
      NA,
      NA,
      NA,
      NA,
      NA,
      NA
    )),
    sc_latest_submission = c(
      NA, NA, NA, NA, NA, NA, NA, NA, "2019Q1", "2019Q2", "2019Q3", "2019Q4",
      "2019Q1", "2019Q2", "2019Q3", "2019Q4"
    )
  )

  # Expect snapshot
  expect_snapshot(as.data.frame(
    test_tibble %>%
      mutate(stay = calculate_stay("1920", start_date, end_date, sc_latest_submission))
  ))
})
