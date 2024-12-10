test_that("Check year valid works for specific datasets ", {
  # year <= "1415"
  expect_false(check_year_valid("1314", "homelessness"))
  expect_false(check_year_valid("1213", "cmh"))
  expect_false(check_year_valid("1112", "dn"))

  # year <= "1516"
  expect_false(check_year_valid("1415", "homelessness"))
  expect_false(check_year_valid("1516", "homelessness"))
  expect_false(check_year_valid("1415", "cmh"))
  expect_false(check_year_valid("1516", "cmh"))
  expect_false(check_year_valid("1415", "dn"))
  expect_true(check_year_valid("1516", "dn"))
  expect_true(check_year_valid("1415", "mh"))
  expect_true(check_year_valid("1516", "maternity"))

  # year <= "1617"
  expect_false(check_year_valid("1415", "at"))
  expect_false(check_year_valid("1516", "at"))
  expect_false(check_year_valid("1617", "at"))
  expect_true(check_year_valid("1718", "at"))
  expect_false(check_year_valid("1415", "ch"))
  expect_false(check_year_valid("1516", "ch"))
  expect_false(check_year_valid("1617", "ch"))
  expect_true(check_year_valid("1718", "ch"))
  expect_false(check_year_valid("1415", "hc"))
  expect_false(check_year_valid("1516", "hc"))
  expect_false(check_year_valid("1617", "hc"))
  expect_true(check_year_valid("1718", "hc"))
  expect_false(check_year_valid("1415", "sds"))
  expect_false(check_year_valid("1516", "sds"))
  expect_false(check_year_valid("1617", "sds"))
  expect_true(check_year_valid("1718", "sds"))


  # year >= "2122"
  expect_false(check_year_valid("2122", "cmh"))
  expect_false(check_year_valid("2122", "dn"))
  expect_true(check_year_valid("2122", "homelessness"))
  expect_true(check_year_valid("2122", "mh"))
  expect_true(check_year_valid("2122", "maternity"))

  # NSUs
  expect_true(check_year_valid("1415", "nsu"))
  expect_true(check_year_valid("1516", "nsu"))
  expect_true(check_year_valid("1617", "nsu"))
  expect_true(check_year_valid("1718", "nsu"))
  expect_true(check_year_valid("1819", "nsu"))
  expect_true(check_year_valid("1920", "nsu"))
  expect_true(check_year_valid("2021", "nsu"))
  expect_true(check_year_valid("2122", "nsu"))
  expect_true(check_year_valid("2223", "nsu"))
  expect_true(check_year_valid("2324", "nsu"))
  expect_false(check_year_valid("2425", "nsu"))

  # SPARRA
  expect_false(check_year_valid("1415", "sparra"))
  expect_true(check_year_valid("1516", "sparra"))
  expect_true(check_year_valid("1617", "sparra"))
  expect_true(check_year_valid("1718", "sparra"))
  expect_true(check_year_valid("1819", "sparra"))
  expect_true(check_year_valid("1920", "sparra"))
  expect_true(check_year_valid("2021", "sparra"))
  expect_true(check_year_valid("2122", "sparra"))
  expect_true(check_year_valid("2122", "sparra"))
  expect_true(check_year_valid("2223", "sparra"))
  expect_true(check_year_valid("2324", "sparra"))
  expect_true(check_year_valid("2425", "sparra"))

  # HHG
  expect_false(check_year_valid("1415", "hhg"))
  expect_false(check_year_valid("1516", "hhg"))
  expect_false(check_year_valid("1617", "hhg"))
  expect_false(check_year_valid("1718", "hhg"))
  expect_true(check_year_valid("1819", "hhg"))
  expect_true(check_year_valid("1920", "hhg"))
  expect_true(check_year_valid("2021", "hhg"))
  expect_true(check_year_valid("2122", "hhg"))
  expect_true(check_year_valid("2122", "hhg"))
  expect_true(check_year_valid("2223", "hhg"))
  expect_false(check_year_valid("2324", "hhg"))
  expect_false(check_year_valid("2425", "hhg"))

  # Other extracts not within boundaries
  expect_true(check_year_valid("2021", "acute"))
  expect_true(check_year_valid("1920", "maternity"))
  expect_true(check_year_valid("1819", "mh"))
  expect_true(check_year_valid("1718", "outpatients"))

  # Social care
  expect_true(check_year_valid("1819", "at"))
  expect_true(check_year_valid("1920", "ch"))
  expect_true(check_year_valid("2021", "hc"))
  expect_true(check_year_valid("2122", "sds"))
})
