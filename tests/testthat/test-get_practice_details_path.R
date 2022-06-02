test_that("GP clusters file (Practice Details) path works", {
  expect_s3_class(get_practice_details_path(ext = "zsav"), "fs_path")
  expect_error(get_practice_details_path(ext = "rds"))
})
