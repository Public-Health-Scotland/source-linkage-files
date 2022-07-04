test_that("is_date_in_year errors as expected", {
  expect_error(
    is_date_in_year(Sys.time(), "2017"),
    "The year has been entered in the wrong format"
  )

  expect_error(
    is_date_in_year("2017-04-01", "1718"),
    "not a recognized date-time"
  )
})

test_that("is_date_in_year works as expected", {
  expect_type(is_date_in_year(Sys.time(), "1718"), "logical")

  expect_true(is_date_in_year(as.Date("2017-04-01"), "1718"))
  expect_true(is_date_in_year(as.Date("2018-03-31"), "1718"))

  expect_false(is_date_in_year(as.Date("2017-03-31"), "1718"))
  expect_false(is_date_in_year(as.Date("2018-04-01"), "1718"))
})
