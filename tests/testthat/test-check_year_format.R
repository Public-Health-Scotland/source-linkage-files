test_that("Check year format works", {
  expect_equal(check_year_format("1718"), "1718")
  expect_equal(check_year_format("1718", format = "fyyear"), "1718")
  expect_equal(check_year_format("2017", format = "alternate"), "2017")

  expect_equal(check_year_format(1718), "1718") %>%
    expect_warning("`year` should be a character")
  expect_equal(check_year_format(1718, format = "fyyear"), "1718") %>%
    expect_warning("`year` should be a character")
  expect_equal(check_year_format(2017, format = "alternate"), "2017") %>%
    expect_warning("`year` should be a character")

  expect_error(check_year_format("2017"))
  expect_error(check_year_format("2017", format = "fyyear"))
  expect_error(check_year_format("1718", format = "alternate"))

  expect_error(check_year_format(2017)) %>%
    expect_warning()
  expect_error(check_year_format(2017, format = "fyyear")) %>%
    expect_warning()
  expect_error(check_year_format(1718, format = "alternate")) %>%
    expect_warning()
})
