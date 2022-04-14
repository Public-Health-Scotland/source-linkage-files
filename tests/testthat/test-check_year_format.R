test_that("Check year format works", {
  # Usual case
  expect_equal(check_year_format("1718"), "1718")
  expect_equal(check_year_format("1718", format = "fyyear"), "1718")
  expect_equal(check_year_format("2017", format = "alternate"), "2017")

  # Vector of years
  expect_equal(check_year_format(c("1718", "1819", "1920")), c("1718", "1819", "1920"))
  expect_equal(
    check_year_format(c("2017", "2018", "2019"), format = "alternate"),
    c("2017", "2018", "2019")
  )

  # Year as a numeric
  expect_equal(check_year_format(1718), "1718") %>%
    expect_warning("`year` should be a character")
  expect_equal(check_year_format(1718, format = "fyyear"), "1718") %>%
    expect_warning("`year` should be a character")
  expect_equal(check_year_format(2017, format = "alternate"), "2017") %>%
    expect_warning("`year` should be a character")

  # Vectors
  expect_equal(check_year_format(c(1718, 1819, 1920)), c("1718", "1819", "1920")) %>%
    expect_warning("`year` should be a character")
  expect_equal(
    check_year_format(c(2017, 2018, 2019), format = "alternate"),
    c("2017", "2018", "2019")
  ) %>%
    expect_warning("`year` should be a character")

  # Incorrect fomat
  expect_error(
    check_year_format("2017"),
    "Try again using the standard form, e.g. `1718`"
  )
  expect_error(
    check_year_format("2017", format = "fyyear"),
    "Try again using the standard form, e.g. `1718`"
  )
  expect_error(
    check_year_format("1718", format = "alternate"),
    "Try again using the alternate form, e.g. `2017`"
  )

  # Vector of years
  expect_error(
    check_year_format(c("2017", "2018", "2019")),
    "Try again using the standard form, e.g. `1718`"
  )
  expect_error(
    check_year_format(c("1718", "1819", "1920"), format = "alternate"),
    "Try again using the alternate form, e.g. `2017`"
  )

  # Only one incorrect
  expect_error(
    check_year_format(c("1718", "2018", "1920")),
    "Try again using the standard form, e.g. `1718`"
  )

  expect_error(
    check_year_format(2017),
    "Try again using the standard form, e.g. `1718`"
  ) %>%
    expect_warning("`year` should be a character")
  expect_error(
    check_year_format(2017, format = "fyyear"),
    "Try again using the standard form, e.g. `1718`"
  ) %>%
    expect_warning("`year` should be a character")
  expect_error(
    check_year_format(1718, format = "alternate"),
    "Try again using the alternate form, e.g. `2017`"
  ) %>%
    expect_warning("`year` should be a character")
})
