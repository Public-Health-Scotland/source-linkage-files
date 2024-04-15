skip_on_ci()

test_that("write_file works", {
  rds_path <- tempfile(fileext = ".rds")
  parquet_path <- tempfile(fileext = ".parquet")

  aq_data <- tibble::as_tibble(datasets::airquality)

  write_file(aq_data, rds_path)
  write_file(aq_data, parquet_path)

  expect_equal(aq_data, readr::read_rds(rds_path))
  expect_equal(aq_data, arrow::read_parquet(parquet_path))

  # Round trip with read_file
  expect_equal(aq_data, read_file(rds_path))
  expect_equal(aq_data, read_file(parquet_path))
})

test_that("write_file errors on unknown extensions", {
  xlsx_path <- tempfile(fileext = ".xlsx")
  zsav_path <- tempfile(fileext = ".zsav")
  fst_path <- tempfile(fileext = ".fst")

  expect_error(write_file(datasets::airquality, xlsx_path))
  expect_error(write_file(datasets::airquality, zsav_path))
  expect_error(write_file(datasets::airquality, fst_path))
})
