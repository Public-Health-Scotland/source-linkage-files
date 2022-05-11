test_that("Costs paths work", {
  expect_s3_class(get_ch_costs_path(ext = "sav"), "fs_path")
  expect_s3_class(get_dn_costs_path(ext = "sav"), "fs_path")
  expect_s3_class(get_gp_ooh_costs_path(ext = "sav"), "fs_path")
})
