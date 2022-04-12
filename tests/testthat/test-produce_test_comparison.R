test_that("produce test comparison function returns data", {
  old_data <- tibble::tibble(
    measure = c("NHS_Ayrshire_and_Arran", "NHS_Borders"),
    value = c(10L, 20L)
  )

  new_data <- tibble::tibble(
    measure = c("NHS_Ayrshire_and_Arran", "NHS_Borders"),
    value = c(15L, 25L)
  )

  outcome <- tibble::tibble(
    measure = c("NHS_Ayrshire_and_Arran", "NHS_Borders"),
    value_old = c(10L, 20L),
    value_new = c(15L, 25L),
    diff = c(5L, 5L),
    pct_change = c('50%', '25%'),
    issue = c(TRUE, TRUE)
  )

  # Check type etc.
  expect_s3_class(produce_test_comparison(old_data, new_data), "tbl_df")
  expect_type(produce_test_comparison(old_data, new_data)$measure, "character")
  expect_type(produce_test_comparison(old_data, new_data)$value_old, "integer")
  expect_type(produce_test_comparison(old_data, new_data)$value_new, "integer")
  expect_equal(produce_test_comparison(old_data, new_data), outcome)
})
