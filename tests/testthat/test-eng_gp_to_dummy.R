test_that("GP English dummy code function returns data", {
  data <- tibble::tibble(gpprac = c("1234", "A1235"))

  expect_s3_class(eng_gp_to_dummy(data, gpprac), "tbl_df")
  expect_length(eng_gp_to_dummy(data, gpprac), length(data))
  expect_equal(nrow(eng_gp_to_dummy(data, gpprac)), nrow(data))
})
