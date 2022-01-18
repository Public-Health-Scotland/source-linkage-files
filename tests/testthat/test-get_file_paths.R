test_that("main SLF directory exists", {
  slf_dir_path <- get_slf_dir()

  expect_true(fs::dir_exists(slf_dir_path))
})


test_that("Costs paths work", {
  expect_s3_class(get_ch_costs_path(), "fs_path")
  expect_s3_class(get_dn_costs_path(), "fs_path")
  expect_s3_class(get_gp_ooh_costs_path(), "fs_path")
})


test_that("SLF Deaths lookup path works", {
  expect_s3_class(get_slf_deaths_path(), "fs_path")
  expect_s3_class(get_slf_deaths_path(previous_update()), "fs_path")
})
