skip_on_ci()

test_that("read_file works", {
  rds_path <- tempfile(fileext = ".rds")
  rds_gz_path <- tempfile(fileext = ".rds.gz")
  csv_path <- tempfile(fileext = ".csv")
  csv_gz_path <- tempfile(fileext = ".csv.gz")
  parquet_path <- tempfile(fileext = ".parquet")

  aq_data <- tibble::as_tibble(datasets::airquality)

  readr::write_rds(aq_data, rds_path)
  readr::write_rds(aq_data, rds_gz_path)
  readr::write_csv(aq_data, csv_path)
  readr::write_csv(aq_data, csv_gz_path)
  arrow::write_parquet(aq_data, parquet_path)

  expect_equal(aq_data, read_file(rds_path))
  expect_equal(aq_data, read_file(rds_gz_path))
  expect_equal(aq_data, read_file(csv_gz_path))
  expect_equal(aq_data, read_file(parquet_path))
})

test_that("read_file errors on unknown extensions", {
  xlsx_path <- tempfile(fileext = ".xlsx")

  openxlsx::write.xlsx(datasets::airquality, xlsx_path)

  expect_error(read_file(xlsx_path))
})
