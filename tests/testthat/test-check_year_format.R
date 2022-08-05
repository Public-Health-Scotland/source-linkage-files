test_that("Check year format works for valid input", {
  # Usual case
  expect_equal(check_year_format("1718"), "1718")
  expect_equal(check_year_format("1718", format = "fyyear"), "1718")
  expect_equal(check_year_format("2017", format = "alternate"), "2017")

  # Vector of years
  expect_equal(
    check_year_format(c("1718", "1819", "1920")),
    c("1718", "1819", "1920")
  )
  expect_equal(
    check_year_format(c("2017", "2018", "2019"), format = "alternate"),
    c("2017", "2018", "2019")
  )
})

test_that("Check year works for numeric input", {
  # Year as a numeric
  expect_equal(check_year_format(1718), "1718") %>%
    expect_message("`year` will be converted to a character")
  expect_equal(check_year_format(1718, format = "fyyear"), "1718") %>%
    expect_message("`year` will be converted to a character")
  expect_equal(check_year_format(2017, format = "alternate"), "2017") %>%
    expect_message("`year` will be converted to a character")

  # Vectors
  expect_equal(
    check_year_format(c(1718, 1819, 1920)),
    c("1718", "1819", "1920")
  ) %>%
    expect_message("`year` will be converted to a character")

  expect_equal(
    check_year_format(c(2017, 2018, 2019), format = "alternate"),
    c("2017", "2018", "2019")
  ) %>%
    expect_message("`year` will be converted to a character")
})

test_that("Check year errors properly for single year input", {
  expect_error(
    check_year_format("2017"),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 1718}"))
  )
  expect_error(
    check_year_format("2017", format = "fyyear"),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 1718}"))
  )
  expect_error(
    check_year_format("1718", format = "alternate"),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 2017}"))
  )
})

test_that("Check year errors properly for single year numeric input", {
  expect_error(
    check_year_format(2017),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 1718}"))
  ) %>%
    expect_message("`year` will be converted to a character")
  expect_error(
    check_year_format(2017, format = "fyyear"),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 1718}"))
  ) %>%
    expect_message("`year` will be converted to a character")
  expect_error(
    check_year_format(1718, format = "alternate"),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 2017}"))
  ) %>%
    expect_message("`year` will be converted to a character")
})

test_that("Check year errors properly for vector input ", {
  # Vector of years
  expect_error(
    check_year_format(c("2017", "2018", "2019")),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 1718}"))
  )
  expect_error(
    check_year_format(c("1718", "1819", "1920"), format = "alternate"),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 2017}"))
  )

  # Only one incorrect
  expect_error(
    check_year_format(c("1718", "2018", "1920")),
    suppressMessages(cli::cli_text("Try again using the standard form, e.g. {.val 1718}"))
  )
})
