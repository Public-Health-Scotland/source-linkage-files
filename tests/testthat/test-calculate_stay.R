test_that("Can return correct length of stay", {
  ## Single calculations

  # Normal calculation - no sc_qtr supplied
  # if start and end dates are both supplied, calculate length of stay

  # Start before FY, end during FY
  expect_equal(
    calculate_stay("1920", as.Date("2019/03/31"), as.Date("2019/10/31")),
    214L
  )
  # Start during FY, end during FY
  expect_equal(
    calculate_stay("1920", as.Date("2019/06/30"), as.Date("2019/08/31")),
    62L
  )
  # Start before FY, end after FY
  expect_equal(
    calculate_stay("1920", as.Date("2019/01/01"), as.Date("2020/04/01")),
    456L
  )
  # Start during FY, end after FY
  expect_equal(
    calculate_stay("1920", as.Date("2019/04/01"), as.Date("2020/07/01")),
    457L
  )

  # Normal calculation - no sc_qtr supplied
  # if start date supplied but end date missing, use dummy date (end_FY + 1) to calculate length of stay

  # Start before FY, end missing
  expect_equal(
    calculate_stay("1920", as.Date("2019/03/31"), lubridate::NA_Date_),
    367L
  )
  # Start during FY, end missing
  expect_equal(
    calculate_stay("1920", as.Date("2019/06/30"), lubridate::NA_Date_),
    276L
  )
  # Start before FY, end missing
  expect_equal(
    calculate_stay("1920", as.Date("2019/01/01"), lubridate::NA_Date_),
    456L
  )
  # Start during FY, end missing
  expect_equal(
    calculate_stay("1920", as.Date("2019/04/01"), lubridate::NA_Date_),
    366L
  )


  # SC calculation - sc_qtr supplied
  # if start date supplied but end date missing, use end_qtr to calculate length of stay

  # Start before FY, end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2019/03/31"),
      lubridate::NA_Date_,
      "2019Q1"
    ),
    92L
  )
  # Start during FY, end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2019/06/30"),
      lubridate::NA_Date_,
      "2019Q2"
    ),
    93L
  )
  # Start before FY, end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2019/01/01"),
      lubridate::NA_Date_,
      "2019Q3"
    ),
    365L
  )
  # Start during FY, end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2019/04/01"),
      lubridate::NA_Date_,
      "2019Q4"
    ),
    366L
  )

  # SC calculation - sc_qtr supplied
  # if qtr_end < start_date then set to next qtr to calculate length of stay

  # qtr_end < start_date , end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2019/07/31"),
      lubridate::NA_Date_,
      "2019Q1"
    ),
    62L
  )
  # qtr_end < start_date , end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2019/10/31"),
      lubridate::NA_Date_,
      "2019Q2"
    ),
    62L
  )
  # qtr_end < start_date , end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2020/01/31"),
      lubridate::NA_Date_,
      "2019Q3"
    ),
    61L
  )
  # qtr_end < start_date , end missing
  expect_equal(
    calculate_stay(
      "1920",
      as.Date("2020/04/30"),
      lubridate::NA_Date_,
      "2019Q4"
    ),
    62L
  )

  # SC calculation - if sc_qtr is supplied but end_date is not missing use end_date
  # Start before FY, end during FY
  expect_equal(calculate_stay(
    "1920",
    as.Date("2019/03/31"),
    as.Date("2019/10/31"),
    "2019Q1"
  ), 214L)
  # Start during FY, end during FY
  expect_equal(calculate_stay(
    "1920",
    as.Date("2019/06/30"),
    as.Date("2019/08/31"),
    "2019Q2"
  ), 62L)
  # Start before FY, end after FY
  expect_equal(calculate_stay(
    "1920",
    as.Date("2019/01/01"),
    as.Date("2020/04/01"),
    "2019Q3"
  ), 456L)
  # Start during FY, end after FY
  expect_equal(calculate_stay(
    "1920",
    as.Date("2019/04/01"),
    as.Date("2020/07/01"),
    "2019Q4"
  ), 457L)
})

test_that("Can calculate the correct stay for vectors of dates", {
  # Normal calculation - no sc_qtr supplied
  # if start and end dates are both supplied, calculate length of stay

  # Start before FY, end during FY
  expect_equal(
    calculate_stay(
      "1920",
      as.Date(
        c(
          "2019/03/31", "2019/06/30",
          "2019/01/01", "2019/04/01"
        )
      ),
      as.Date(
        c(
          "2019/10/31", "2019/08/31",
          "2020/04/01", "2020/07/01"
        )
      )
    ),
    c(214L, 62L, 456L, 457L)
  )

  # Normal calculation - no sc_qtr supplied
  # if start date supplied but end date missing, use dummy date (end_FY + 1) to calculate length of stay
  expect_equal(
    calculate_stay(
      "1920",
      as.Date(
        c(
          "2019/03/31", "2019/06/30",
          "2019/01/01", "2019/04/01"
        )
      ),
      as.Date(c(NA, NA, NA, NA))
    ),
    c(367L, 276L, 456L, 366L)
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
    c(92L, 93L, 365L, 366L)
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
    c(62L, 62L, 61L, 62L)
  )

  # SC calculation
  # If sc_qtr is supplied but end_date is not missing use end_date
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
      )),
      c("2019Q1", "2019Q2", "2019Q3", "2019Q4")
    ),
    c(214L, 62L, 456L, 457L)
  )
})

test_that("Calculate stay works well in the normal use case", {
  expect_snapshot(
    tibble::tribble(
      ~start_date,                ~end_date,
      as.Date("2019-03-31"),      as.Date("2019-10-31"),
      as.Date("2019-06-30"),      as.Date("2019-08-31"),
      as.Date("2019-01-01"),      as.Date("2020-04-01"),
      as.Date("2019-04-01"),      as.Date("2020-07-01"),
      as.Date("2019-03-31"),      lubridate::NA_Date_,
      as.Date("2019-06-30"),      lubridate::NA_Date_,
      as.Date("2019-01-01"),      lubridate::NA_Date_,
      as.Date("2019-04-01"),      lubridate::NA_Date_
    ) %>%
      dplyr::mutate(stay = calculate_stay(
        "1920",
        start_date,
        end_date
      ))
  )
})

test_that("Calculate stay works well in the Social Care use case", {
  expect_snapshot(
    tibble::tribble(
      ~start_date, ~end_date, ~sc_qtr,
      as.Date("2019-03-31"), lubridate::NA_Date_, "2019Q1",
      as.Date("2019-06-30"), lubridate::NA_Date_, "2019Q2",
      as.Date("2019-01-01"), lubridate::NA_Date_, "2019Q3",
      as.Date("2019-04-01"), lubridate::NA_Date_, "2019Q4",
      as.Date("2019-07-31"), lubridate::NA_Date_, "2019Q1",
      as.Date("2019-10-31"), lubridate::NA_Date_, "2019Q2",
      as.Date("2020-01-31"), lubridate::NA_Date_, "2019Q3",
      as.Date("2020-04-30"), lubridate::NA_Date_, "2019Q4",
      as.Date("2019-03-31"), as.Date("2019-10-31"), "2019Q1",
      as.Date("2019-06-30"), as.Date("2019-08-31"), "2019Q2",
      as.Date("2019-01-01"), as.Date("2020-04-01"), "2019Q3",
      as.Date("2019-04-01"), as.Date("2020-07-01"), "2019Q4"
    ) %>%
      dplyr::mutate(stay = calculate_stay(
        "1920",
        start_date,
        end_date,
        sc_qtr
      ))
  )
})
