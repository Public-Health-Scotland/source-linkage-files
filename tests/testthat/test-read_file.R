test_that("read_file works", {
  rds_path <- tempfile(fileext = ".rds")
  fst_path <- tempfile(fileext = ".fst")
  sav_path <- tempfile(fileext = ".sav")
  zsav_path <- tempfile(fileext = ".zsav")
  csv_path <- tempfile(fileext = ".csv")
  csv_gz_path <- tempfile(fileext = ".csv.gz")
  parquet_path <- tempfile(fileext = ".parquet")

  aq_data <- tibble::as_tibble(datasets::airquality)

  readr::write_rds(aq_data, rds_path)
  fst::write_fst(aq_data, fst_path)
  haven::write_sav(aq_data, sav_path)
  haven::write_sav(aq_data, zsav_path, compress = "zsav")
  readr::write_csv(aq_data, csv_path)
  readr::write_csv(aq_data, csv_gz_path)
  arrow::write_parquet(aq_data, parquet_path)

  expect_equal(aq_data, read_file(rds_path))
  expect_equal(aq_data, tibble::as_tibble(read_file(fst_path)))
  expect_equal(aq_data, haven::zap_formats(read_file(sav_path)))
  expect_equal(aq_data, haven::zap_formats(read_file(zsav_path)))
  expect_equal(aq_data, read_file(csv_gz_path))
  expect_equal(aq_data, read_file(parquet_path))
})

test_that("read_file errors on unknown extensions", {
  xlsx_path <- tempfile(fileext = ".xlsx")

  openxlsx::write.xlsx(datasets::airquality, xlsx_path)

  expect_error(read_file(xlsx_path))
})
