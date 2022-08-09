test_that("fyyear to year works for valid inputs", {
  expect_equal(convert_fyyear_to_year("1112"), "2011")
  expect_equal(convert_fyyear_to_year("1213"), "2012")
  expect_equal(convert_fyyear_to_year("1718"), "2017")
  expect_equal(convert_fyyear_to_year("1819"), "2018")
  expect_equal(convert_fyyear_to_year("1920"), "2019")
  expect_equal(convert_fyyear_to_year("2021"), "2020")
  expect_equal(convert_fyyear_to_year("2122"), "2021")

  expect_equal(
    convert_fyyear_to_year(c("1718", "1819", "1920")),
    c("2017", "2018", "2019")
  )
})

test_that("fyyear to year errors properly on bad inputs", {
  expect_error(
    convert_fyyear_to_year("2018"),
    "The `year` has been entered in the wrong format\\."
  )

  expect_message(
    convert_fyyear_to_year(1819),
    "`year` will be converted to a character"
  )

  expect_message(
    convert_fyyear_to_year(2018),
    "`year` will be converted to a character"
  ) %>%
    expect_error("The `year` has been entered in the wrong format\\.")
})
