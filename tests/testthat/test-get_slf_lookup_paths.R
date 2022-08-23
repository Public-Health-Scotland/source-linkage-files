test_that("SLF postcode lookup file paths work", {
  expect_s3_class(get_slf_postcode_path(), "fs_path")
  expect_s3_class(get_slf_postcode_path(update = previous_update(), ext = "zsav"), "fs_path")
})

test_that("SLF GP practice lookup file paths work", {
  expect_s3_class(get_slf_gpprac_path(), "fs_path")
  expect_s3_class(get_slf_gpprac_path(update = previous_update(), ext = "zsav"), "fs_path")
})

test_that("SLF Deaths lookup path works", {
  expect_s3_class(get_slf_deaths_path(), "fs_path")
  expect_s3_class(get_slf_deaths_path(previous_update(), ext = "zsav"), "fs_path")
})

test_that("SLF Care Home names lookup path works", {
  expect_s3_class(get_slf_ch_name_lookup_path(), "fs_path")
  expect_s3_class(get_slf_ch_name_lookup_path(previous_update(), ext = "zsav"), "fs_path")
})
