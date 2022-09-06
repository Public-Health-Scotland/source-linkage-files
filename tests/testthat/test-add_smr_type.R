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
  expect_equal(add_smr_type(recid = "CMH"), "Comm-MH")
  expect_equal(add_smr_type(recid = "DN"), "DN")
  expect_equal(add_smr_type(recid = "01B", ipdc = "I"), "Acute-IP")
  expect_equal(add_smr_type(recid = "01B", ipdc = "D"), "Acute-DC")
  expect_equal(add_smr_type(recid = "GLS", ipdc = "I"), "GLS-IP")
  expect_equal(add_smr_type(recid = "HC", hc_service = 1), "HC-Non-Per")
})

# Vector input
test_that("SMR type works for vector input", {
  expect_equal(
    add_smr_type(recid = c("04B", "00B", "PIS", "AE2", "NRS", "CMH")),
    c("Psych-IP", "Outpatient", "PIS", "A & E", "NRS Deaths", "Comm-MH")
  )
  expect_equal(
    add_smr_type(recid = c("02B", "02B", "02B"), mpat = c("5", "6", "A")),
    c("Matern-IP", "Matern-DC", "Matern-IP")
  )
  expect_equal(
    add_smr_type(recid = c("01B", "01B", "GLS"), ipdc = c("I", "D", "I")),
    c("Acute-IP", "Acute-DC", "GLS-IP")
  )
})

# Informational messages
test_that("Warnings return as expected", {
  expect_warning(
    add_smr_type(recid = c("00B", "AE2", "Bum", "PIS"))
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
  expect_error(
    add_smr_type(recid = c(NA, NA, "04B"))
  )
  expect_error(
    add_smr_type(recid = c("02B", "02B"), mpat = c(NA, "1"))
  )
  expect_error(
    add_smr_type(recid = c("01B", "CMH"), mpat = c("1", "2"))
  )
  expect_error(
    add_smr_type(recid = c("01B", "GLS"))
  )
})
