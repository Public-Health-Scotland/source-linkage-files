test_that("Get existing data works", {
  dummy_new_data <- tibble(year = "1920",
                           recid = "04B",
                           chi = 1,
                           diag1 = 1,
                           diag2 = 2)

  slf_data <- get_existing_data_for_tests(dummy_new_data)

  expect_named(slf_data, c("chi", "year", "recid", "diag1", "diag2"))
  expect_gte(nrow(slf_data), 20000)
  expect_equal(unique(slf_data$recid), "04B")
  expect_equal(unique(slf_data$year), "1920")
  expect_false(all(slf_data$chi == ""))
  expect_false(all(slf_data$diag1 == ""))
  expect_false(all(slf_data$diag2 == ""))
})
