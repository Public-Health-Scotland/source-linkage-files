test_that("year to fyyear works for valid inputs", {
  expect_equal(convert_year_to_fyyear("2011"), "1112")
  expect_equal(convert_year_to_fyyear("2012"), "1213")
  expect_equal(convert_year_to_fyyear("2017"), "1718")
  expect_equal(convert_year_to_fyyear("2018"), "1819")
  expect_equal(convert_year_to_fyyear("2019"), "1920")
  expect_equal(convert_year_to_fyyear("2020"), "2021")
  expect_equal(convert_year_to_fyyear("2021"), "2122")

  expect_equal(
    convert_year_to_fyyear(c("2017", "2018", "2019")),
    c("1718", "1819", "1920")
  )
})

test_that("Will respond correctly to weird inputs", {
  expect_equal(
    convert_year_to_fyyear(c("2017", "1917")),
    c("1718", "1718")
  ) %>%
    expect_warning("A value was not in the 21st century i.e. not \"20xx\".+?\"1917\" -> \"1718\"")
})
