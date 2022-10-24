skip_on_ci()

test_that("HHG file path works", {
  expect_s3_class(get_hhg_path("1920"), "fs_path")
  expect_s3_class(get_hhg_path("1920", ext = "zsav"), "fs_path")

  expect_error(get_hhg_path(), "\"year\" is missing, with no default")
})


test_that("SPARRA file path works", {
  expect_s3_class(get_sparra_path("1920"), "fs_path")
  expect_s3_class(get_sparra_path("1920", ext = "zsav"), "fs_path")

  expect_error(get_sparra_path(), "\"year\" is missing, with no default")
})
