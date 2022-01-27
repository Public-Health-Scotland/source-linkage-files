

test_that("Can convert a year from normal financial year to the alternate form", {
  fyyear <- c(
    "1718",
    "1819",
    "1920",
    "2021",
    "2122",
    "1112"
  )

  expect_equal(
    convert_fyyear_to_year(fyyear),
    c(
      "2017",
      "2018",
      "2019",
      "2020",
      "2021",
      "2011"
    )
  )
})

test_that("Can convert a year from normal financial year to the alternate form", {
  expect_error(convert_fyyear_to_year(
    2018,
    "Year has been entered in the wrong format,
                                      try again using form `1718` or use function
                                      `convert_year_to_fyyear` to convert to the
                                      financial year form."
  ))
})





test_that("Can convert a year from alternate form to normal financial year", {
  year <- c(
    "2017",
    "2018",
    "2019",
    "2020",
    "2021",
    "2011"
  )

  expect_equal(
    convert_year_to_fyyear(year),
    c(
      "1718",
      "1819",
      "1920",
      "2021",
      "2122",
      "1112"
    )
  )
})


test_that("Can convert a year from alternate form to normal financial year", {
  expect_error(
    convert_year_to_fyyear(1819),
    "Year has been entered in the wrong format"
  )
})



test_that("Can convert a year from alternate form to normal financial year", {
  expect_error(convert_year_to_fyyear(
    1819,
    "Year has been entered in the wrong format,
                                      try again using form `2017` or use function
                                      `convert_fyyear_to_year` to convert to alternate
                                      year form."
  ))
})
