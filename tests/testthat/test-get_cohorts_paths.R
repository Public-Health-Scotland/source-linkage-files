skip_on_ci()

test_that("Cohorts paths work", {
  expect_s3_class(get_demog_cohorts_path("1920", ext = "zsav"), "fs_path")
  expect_s3_class(get_service_use_cohorts_path("1920", ext = "zsav"), "fs_path")
})
