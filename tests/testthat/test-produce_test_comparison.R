test_that("produce test comparison function returns data", {
  old_data <- tibble::tibble(
    measure = c("NHS_Ayrshire_and_Arran", "NHS_Borders"),
    value = c(1234L, 5678L)
  )

  new_data <- tibble::tibble(
    measure = c("NHS_Ayrshire_and_Arran", "NHS_Borders"),
    value = c(2345L, 6789L)
  )

  outcome <- tibble::tibble(
    measure = c("NHS_Ayrshire_and_Arran", "NHS_Borders"),
    value_old = c(1234L, 5678L),
    value_new = c(2345L, 6789L),
    diff = c(1111L, 1111L),
    pctChange = c(90.032415, 19.566749),
    issue = c(1L, 1L)
  )

  # Check type etc.
  expect_s3_class(produce_test_comparison(old_data, new_data), "tbl_df")
  expect_type(produce_test_comparison(old_data, new_data)$measure, "character")
  expect_type(produce_test_comparison(old_data, new_data)$value_old, "integer")
  expect_type(produce_test_comparison(old_data, new_data)$value_new, "integer")
  expect_equal(produce_test_comparison(old_data, new_data), outcome)
})
