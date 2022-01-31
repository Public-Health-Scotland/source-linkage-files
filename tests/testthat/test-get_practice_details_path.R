test_that("GP clusters file (Practice Details) path works", {
  expect_s3_class(get_practice_details_path(), "fs_path")
  expect_error(get_practice_details_path(ext = "rds"))
})
