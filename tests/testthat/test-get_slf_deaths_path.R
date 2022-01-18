test_that("SLF Deaths lookup path works", {
  expect_s3_class(get_slf_deaths_path(), "fs_path")
  expect_s3_class(get_slf_deaths_path(previous_update()), "fs_path")
})
