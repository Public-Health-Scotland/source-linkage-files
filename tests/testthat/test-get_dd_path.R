skip_on_ci()

test_that("Delayed discharges path works", {
  expect_s3_class(get_dd_path(ext = "rds"), "fs_path")
})
