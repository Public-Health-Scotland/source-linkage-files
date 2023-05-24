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

  # year <= "1617"
  expect_equal(check_year_valid("1415", "AT"), FALSE)
  expect_equal(check_year_valid("1516", "AT"), FALSE)
  expect_equal(check_year_valid("1617", "AT"), FALSE)
  expect_equal(check_year_valid("1718", "AT"), TRUE)
  expect_equal(check_year_valid("1415", "CH"), FALSE)
  expect_equal(check_year_valid("1516", "CH"), FALSE)
  expect_equal(check_year_valid("1617", "CH"), FALSE)
  expect_equal(check_year_valid("1718", "CH"), TRUE)
  expect_equal(check_year_valid("1415", "HC"), FALSE)
  expect_equal(check_year_valid("1516", "HC"), FALSE)
  expect_equal(check_year_valid("1617", "HC"), FALSE)
  expect_equal(check_year_valid("1718", "HC"), TRUE)
  expect_equal(check_year_valid("1415", "SDS"), FALSE)
  expect_equal(check_year_valid("1516", "SDS"), FALSE)
  expect_equal(check_year_valid("1617", "SDS"), FALSE)
  expect_equal(check_year_valid("1718", "SDS"), TRUE)


  # year >= "2122"
  expect_equal(check_year_valid("2122", "CMH"), FALSE)
  expect_equal(check_year_valid("2122", "DN"), FALSE)
  expect_equal(check_year_valid("2122", "Homelessness"), TRUE)
  expect_equal(check_year_valid("2122", "MH"), TRUE)
  expect_equal(check_year_valid("2122", "Maternity"), TRUE)

  # NSUs
  expect_equal(check_year_valid("1415", "NSU"), TRUE)
  expect_equal(check_year_valid("1516", "NSU"), TRUE)
  expect_equal(check_year_valid("1617", "NSU"), TRUE)
  expect_equal(check_year_valid("1718", "NSU"), TRUE)
  expect_equal(check_year_valid("1819", "NSU"), TRUE)
  expect_equal(check_year_valid("1920", "NSU"), TRUE)
  expect_equal(check_year_valid("2021", "NSU"), TRUE)
  expect_equal(check_year_valid("2122", "NSU"), TRUE)
  expect_equal(check_year_valid("2223", "NSU"), FALSE)

  # Other extracts not within boundaries
  expect_equal(check_year_valid("2021", "Acute"), TRUE)
  expect_equal(check_year_valid("1920", "Maternity"), TRUE)
  expect_equal(check_year_valid("1819", "MH"), TRUE)
  expect_equal(check_year_valid("1718", "Outpatients"), TRUE)

  # Social care
  expect_equal(check_year_valid("1819", "AT"), TRUE)
  expect_equal(check_year_valid("1920", "CH"), TRUE)
  expect_equal(check_year_valid("2021", "HC"), TRUE)
  expect_equal(check_year_valid("2122", "SDS"), TRUE)
})
