test_that("Can convert a year from normal financial year to the alternate form", {
  fyyear <- c(
    1718,
    1718,
    1819,
    1819,
    1920,
    1920,
    2021,
    2021,
    2122,
    2122
  )
  
  expect_equal(
    convert_fyyear_to_year(fyyear),
    c('2017',
      '2017',
      '2018',
      '2018',
      '2019',
      '2019',
      '2020',
      '2020',
      '2021',
      '2021'
      )
  )
})



test_that("Can convert a year from alternate form to normal financial year", {
  year <- c(
    '2017',
    '2017',
    '2018',
    '2018',
    '2019',
    '2019',
    '2020',
    '2020',
    '2021',
    '2021'
  )
  
  expect_equal(
    convert_year_to_fyyear(year),
      c(1718,
        1718,
        1819,
        1819,
        1920,
        1920,
        2021,
        2021,
        2122,
        2122
      )
    )
})
