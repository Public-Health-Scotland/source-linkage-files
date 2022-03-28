test_that("GP English dummy code function returns data", {
  data <- tibble::tibble(gpprac = c("1234", "A1235"))

  # Check type etc.
  expect_s3_class(convert_eng_gpprac_to_dummy(data, gpprac), "tbl_df")
  expect_length(convert_eng_gpprac_to_dummy(data, gpprac), length(data))
  expect_equal(nrow(convert_eng_gpprac_to_dummy(data, gpprac)), nrow(data))

  # Check contents
  expect_type(convert_eng_gpprac_to_dummy(data, gpprac)$gpprac, "integer")
  expect_equal(convert_eng_gpprac_to_dummy(data, gpprac)$gpprac, c(1234, 9995))
})
