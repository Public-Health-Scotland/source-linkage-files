skip_on_ci()

test_that("NSU files exist", {
  expect_s3_class(get_nsu_path(year = "1718"), "fs_path")
  expect_s3_class(get_nsu_path(year = "1920"), "fs_path")
  expect_s3_class(get_nsu_path(year = "2122"), "fs_path")
})
