test_that("Accurately compute mid year age", {
  expect_equal(
    compute_mid_year_age("1718", lubridate::make_date("2000")),
    phsmethods::age_calculate(
      lubridate::make_date("2000"),
      lubridate::make_date("2017", 9L, 30L)
    )
  )
  expect_equal(
    compute_mid_year_age("2021", lubridate::make_date("1999") + 1:1000),
    phsmethods::age_calculate(
      lubridate::make_date("1999") + 1:1000,
      lubridate::make_date("2020", 9L, 30L)
    )
  )
})
