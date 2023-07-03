test_that("Check year valid works for specific datasets ", {
  # year <= "1415"
  expect_false(check_year_valid("1314", "Homelessness"))
  expect_false(check_year_valid("1213", "CMH"))
  expect_false(check_year_valid("1112", "DN"))

  # year <= "1516"
  expect_false(check_year_valid("1415", "Homelessness"))
  expect_false(check_year_valid("1516", "Homelessness"))
  expect_false(check_year_valid("1415", "CMH"))
  expect_false(check_year_valid("1516", "CMH"))
  expect_false(check_year_valid("1415", "DN"))
  expect_true(check_year_valid("1516", "DN"))
  expect_true(check_year_valid("1415", "MH"))
  expect_true(check_year_valid("1516", "Maternity"))

  # year <= "1617"
  expect_false(check_year_valid("1415", "AT"))
  expect_false(check_year_valid("1516", "AT"))
  expect_false(check_year_valid("1617", "AT"))
  expect_true(check_year_valid("1718", "AT"))
  expect_false(check_year_valid("1415", "CH"))
  expect_false(check_year_valid("1516", "CH"))
  expect_false(check_year_valid("1617", "CH"))
  expect_true(check_year_valid("1718", "CH"))
  expect_false(check_year_valid("1415", "HC"))
  expect_false(check_year_valid("1516", "HC"))
  expect_false(check_year_valid("1617", "HC"))
  expect_true(check_year_valid("1718", "HC"))
  expect_false(check_year_valid("1415", "SDS"))
  expect_false(check_year_valid("1516", "SDS"))
  expect_false(check_year_valid("1617", "SDS"))
  expect_true(check_year_valid("1718", "SDS"))


  # year >= "2122"
  expect_false(check_year_valid("2122", "CMH"))
  expect_false(check_year_valid("2122", "DN"))
  expect_true(check_year_valid("2122", "Homelessness"))
  expect_true(check_year_valid("2122", "MH"))
  expect_true(check_year_valid("2122", "Maternity"))

  # NSUs
  expect_true(check_year_valid("1415", "NSU"))
  expect_true(check_year_valid("1516", "NSU"))
  expect_true(check_year_valid("1617", "NSU"))
  expect_true(check_year_valid("1718", "NSU"))
  expect_true(check_year_valid("1819", "NSU"))
  expect_true(check_year_valid("1920", "NSU"))
  expect_true(check_year_valid("2021", "NSU"))
  expect_true(check_year_valid("2122", "NSU"))
  expect_false(check_year_valid("2223", "NSU"))

  # SPARRA
  expect_false(check_year_valid("1415", "SPARRA"))
  expect_true(check_year_valid("1516", "SPARRA"))
  expect_true(check_year_valid("1617", "SPARRA"))
  expect_true(check_year_valid("1718", "SPARRA"))
  expect_true(check_year_valid("1819", "SPARRA"))
  expect_true(check_year_valid("1920", "SPARRA"))
  expect_true(check_year_valid("2021", "SPARRA"))
  expect_true(check_year_valid("2122", "SPARRA"))
  expect_true(check_year_valid("2122", "SPARRA"))
  expect_true(check_year_valid("2223", "SPARRA"))
  expect_false(check_year_valid("2324", "SPARRA"))

  # HHG
  expect_false(check_year_valid("1415", "HHG"))
  expect_false(check_year_valid("1516", "HHG"))
  expect_false(check_year_valid("1617", "HHG"))
  expect_false(check_year_valid("1718", "HHG"))
  expect_true(check_year_valid("1819", "HHG"))
  expect_true(check_year_valid("1920", "HHG"))
  expect_true(check_year_valid("2021", "HHG"))
  expect_true(check_year_valid("2122", "HHG"))
  expect_true(check_year_valid("2122", "HHG"))
  expect_true(check_year_valid("2223", "HHG"))
  expect_false(check_year_valid("2324", "HHG"))
  expect_false(check_year_valid("2425", "HHG"))

  # Other extracts not within boundaries
  expect_true(check_year_valid("2021", "Acute"))
  expect_true(check_year_valid("1920", "Maternity"))
  expect_true(check_year_valid("1819", "MH"))
  expect_true(check_year_valid("1718", "Outpatients"))

  # Social care
  expect_true(check_year_valid("1819", "AT"))
  expect_true(check_year_valid("1920", "CH"))
  expect_true(check_year_valid("2021", "HC"))
  expect_true(check_year_valid("2122", "SDS"))
})
