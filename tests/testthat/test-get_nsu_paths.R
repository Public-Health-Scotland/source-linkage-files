
test_that("NSU file path works", {
  expect_s3_class(get_nsu_path(year = "1920"), "fs_path")
  expect_error(get_nsu_path(year = "1920", ext = "rds"))
})
