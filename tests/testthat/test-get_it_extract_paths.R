test_that("IT extract file paths work", {
  expect_s3_class(get_it_ltc_path(), "fs_path")
  expect_s3_class(get_it_deaths_path(), "fs_path")
  expect_s3_class(get_it_prescribing_path("1920"), "fs_path")
})
