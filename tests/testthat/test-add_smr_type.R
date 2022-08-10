# Single character input
test_that("SMR type works for single input", {
  expect_equal(add_smr_type(recid = "02B", mpat = "0"), "Matern-HB")
  expect_equal(add_smr_type(recid = "02B", mpat = "1"), "Matern-IP")
  expect_equal(add_smr_type(recid = "02B", mpat = "4"), "Matern-DC")
  expect_equal(add_smr_type(recid = "04B"), "Psych-IP")
  expect_equal(add_smr_type(recid = "00B"), "Outpatient")
  expect_equal(add_smr_type(recid = "AE2"), "A & E")
  expect_equal(add_smr_type(recid = "PIS"), "PIS")
  expect_equal(add_smr_type(recid = "NRS"), "NRS Deaths")
})

# Vector input
test_that("SMR type works for vector input", {
  expect_equal(
    add_smr_type(recid = c("04B", "00B", "PIS", "AE2", "NRS")),
    c("Psych-IP", "Outpatient", "PIS", "A & E", "NRS Deaths")
  )
  expect_equal(
    add_smr_type(recid = c("02B", "02B", "02B"), mpat = c("5", "6", "A")),
    c("Matern-IP", "Matern-DC", "Matern-IP")
  )
})

# Informational messages
test_that("Error messages return as expected", {
  expect_message(
    add_smr_type(recid = c(NA, NA, "04B")),
    suppressMessages(cli::cli_inform(c("i" = "Some values of {.var recid} are {.val NA},
                    please check this is populated throughout the data")))
  )
  expect_message(
    add_smr_type(recid = c("02B", "02B"), mpat = c(NA, "1")),
    suppressMessages(cli::cli_inform(c("i" = "In maternity records, {.var mpat} is required to assign
                      an smrtype, and there are some {.val NA} values. Please check the data.")))
  )

  expect_message(
    add_smr_type(recid = c("00B", "AE2", "Bum", "PIS")),
    suppressMessages(cli::cli_inform(c("i" = "One or more values of {.var recid} do not have an
                   assignable {.var smrtype}")))
    )
})

# Errors that abort the function
test_that("Error escapes functions as expected", {
  expect_error(
    add_smr_type(recid = c(NA, NA, NA, NA))
  )
  expect_error(
    add_smr_type(recid = c("02B", "02B", "02B"), mpat = c(NA, NA, NA))

  )
})

