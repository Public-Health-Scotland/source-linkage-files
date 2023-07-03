skip_on_ci()

test_that("Costs files exist", {
  expect_s3_class(get_ch_costs_path(), "fs_path")

  expect_s3_class(get_hc_costs_path(), "fs_path")
  expect_s3_class(get_hc_raw_costs_path(), "fs_path")

  expect_s3_class(get_dn_costs_path(), "fs_path")
  expect_s3_class(get_dn_raw_costs_path(), "fs_path")

  expect_s3_class(get_gp_ooh_costs_path(), "fs_path")
  expect_s3_class(get_gp_ooh_raw_costs_path(), "fs_path")
})
