skip_on_ci()

test_that("Delayed discharges file exists", {
  expect_s3_class(get_dd_path(), "fs_path")
})
