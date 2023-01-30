test_that("Check year valid works for specific datasets ", {

  # <1415
  expect_equal(check_year_valid("1314", "Homelessness"), FALSE)
  expect_equal(check_year_valid("1213", "CMH"), FALSE)
  expect_equal(check_year_valid("1112", "DN"), FALSE)

  # <= 1516
  expect_equal(check_year_valid("1415", "Homelessness"), FALSE)
  expect_equal(check_year_valid("1516", "Homelessness"), FALSE)
  expect_equal(check_year_valid("1617", "Homelessness"), TRUE)
  expect_equal(check_year_valid("1718", "Homelessness"), TRUE)

  expect_equal(check_year_valid("1415", "CMH"), FALSE)
  expect_equal(check_year_valid("1516", "CMH"), FALSE)
  expect_equal(check_year_valid("1617", "CMH"), TRUE)
  expect_equal(check_year_valid("1718", "CMH"), TRUE)

  expect_equal(check_year_valid("1415", "DN"), FALSE)
  expect_equal(check_year_valid("1516", "DN"), TRUE)
  expect_equal(check_year_valid("1617", "DN"), TRUE)
  expect_equal(check_year_valid("1718", "DN"), TRUE)
})
