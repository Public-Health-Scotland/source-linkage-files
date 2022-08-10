test_that("SMR type works", {

  expect_equal(add_smr_type(recid = "02B", mpat = "0"), "Matern-HB")
  expect_equal(add_smr_type(recid = "02B", mpat = "1"), "Matern-IP")
  expect_equal(add_smr_type(recid = "02B", mpat = "4"), "Matern-DC")
  expect_equal(add_smr_type(recid = "04B"), "Psych-IP")
  expect_equal(add_smr_type(recid = "00B"), "Outpatient")
  expect_equal(add_smr_type(recid = "AE2"), "A & E")
  expect_equal(add_smr_type(recid = "PIS"), "PIS")
  expect_equal(add_smr_type(recid = "NRS"), "NRS Deaths")

})
