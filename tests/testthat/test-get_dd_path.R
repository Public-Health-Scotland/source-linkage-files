skip_on_ci()

test_that("Delayed discharges path works", {
  expect_s3_class(get_dd_path(ext = "zsav"), "fs_path")
  expect_error(
    get_dd_path(ext = "rds"),
    "The file.+?[A-Z][a-z]{2}[0-9]{2}_[A-Z][a-z]{2}[0-9]{2}DD_LinkageFile.rds.+?does not exist in.+?/conf/hscdiip/SLF_Extracts/Delayed_Discharges"
  )
})
