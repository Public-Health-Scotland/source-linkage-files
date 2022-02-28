test_that("sum test flags function returns data", {
  input <- tibble::tibble(
    NHS_Ayrshire_and_Arran = c(1L, 0L, 1L, 0L),
    NHS_Borders = c(1L, 0L, 1L, 1L)
  )

  output <- tibble::tibble(
    measure = c("NHS_Ayrshire_and_Arran", "NHS_Borders"),
    value = c(2L, 3L)
  )

  # Check type etc.
  expect_s3_class(sum_test_flags(input), "tbl_df")
  expect_type(sum_test_flags(input)$measure, "character")
  expect_type(sum_test_flags(input)$value, "integer")
  expect_equal(sum_test_flags(input), output)
})
