test_that("date format seems valid", {
  expect_type(boxi_date_format(), "character")
  expect_true(grepl(pattern = "%", x = boxi_date_format()))
})

test_that("matches dates", {
  example_boxi_dates <- c(
    "2017/09/13 00:00:00",
    "2018/03/12 00:00:00",
    "2018/03/01 00:00:00",
    "2018/07/06 00:00:00",
    "2019/03/13 00:00:00",
    "2018/09/04 00:00:00",
    "2019/05/27 00:00:00",
    "2020/05/29 00:00:00",
    "2020/04/28 00:00:00",
    "2019/05/24 00:00:00"
  )

  expect_equal(
    readr::parse_date(example_boxi_dates, format = boxi_date_format()),
    as.Date(c(
      "2017/09/13",
      "2018/03/12",
      "2018/03/01",
      "2018/07/06",
      "2019/03/13",
      "2018/09/04",
      "2019/05/27",
      "2020/05/29",
      "2020/04/28",
      "2019/05/24"
    ))
  )
})
