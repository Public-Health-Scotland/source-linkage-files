test_that("Check year valid works for specific datasets ", {
  # year <= "1415"
  expect_equal(check_year_valid("1314", "Homelessness"), FALSE)
  expect_equal(check_year_valid("1213", "CMH"), FALSE)
  expect_equal(check_year_valid("1112", "DN"), FALSE)

  # year <= "1516"
  expect_equal(check_year_valid("1415", "Homelessness"), FALSE)
  expect_equal(check_year_valid("1516", "Homelessness"), FALSE)
  expect_equal(check_year_valid("1415", "CMH"), FALSE)
  expect_equal(check_year_valid("1516", "CMH"), FALSE)
  expect_equal(check_year_valid("1415", "DN"), FALSE)
  expect_equal(check_year_valid("1516", "DN"), TRUE)
  expect_equal(check_year_valid("1415", "MH"), TRUE)
  expect_equal(check_year_valid("1516", "Maternity"), TRUE)

  # year >= "2122"
  expect_equal(check_year_valid("2122", "CMH"), FALSE)
  expect_equal(check_year_valid("2122", "DN"), FALSE)
  expect_equal(check_year_valid("2122", "Homelessness"), TRUE)
  expect_equal(check_year_valid("2122", "MH"), TRUE)
  expect_equal(check_year_valid("2122", "Maternity"), TRUE)


  # Other extracts not within boundaries
  expect_equal(check_year_valid("2021", "Acute"), TRUE)
  expect_equal(check_year_valid("1920", "Maternity"), TRUE)
  expect_equal(check_year_valid("1819", "MH"), TRUE)
  expect_equal(check_year_valid("1718", "Outpatients"), TRUE)
})
