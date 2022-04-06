test_that("Can convert a year from normal financial year to the alternate form", {
  expect_equal(convert_fyyear_to_year("1112"), "2011")
  expect_equal(convert_fyyear_to_year("1213"), "2012")
  expect_equal(convert_fyyear_to_year("1718"), "2017")
  expect_equal(convert_fyyear_to_year("1819"), "2018")
  expect_equal(convert_fyyear_to_year("1920"), "2019")
  expect_equal(convert_fyyear_to_year("2021"), "2020")
  expect_equal(convert_fyyear_to_year("2122"), "2021")
})

test_that("Responds correctly to bad inputs", {
  expect_error(
    convert_fyyear_to_year("2018"),
    "The year has been entered in the wrong format\\."
  )

  expect_warning(
    convert_fyyear_to_year(1819),
    "`year` should be a character"
  )

  expect_warning(
    convert_fyyear_to_year(2018),
    "`year` should be a character"
  ) %>%
    expect_error("The year has been entered in the wrong format\\.")
})

test_that("Can convert a year from alternate form to normal financial year", {
  expect_equal(convert_year_to_fyyear("2011"), "1112")
  expect_equal(convert_year_to_fyyear("2012"), "1213")
  expect_equal(convert_year_to_fyyear("2017"), "1718")
  expect_equal(convert_year_to_fyyear("2018"), "1819")
  expect_equal(convert_year_to_fyyear("2019"), "1920")
  expect_equal(convert_year_to_fyyear("2020"), "2021")
  expect_equal(convert_year_to_fyyear("2021"), "2122")
})

test_that("Responds correctly to bad inputs", {
  expect_error(
    convert_year_to_fyyear("1819"),
    "The year has been entered in the wrong format\\."
  )

  expect_warning(
    convert_year_to_fyyear(2018),
    "`year` should be a character"
  )

  expect_warning(
    convert_year_to_fyyear(1819),
    "`year` should be a character"
  ) %>%
    expect_error("The year has been entered in the wrong format\\.")
})
