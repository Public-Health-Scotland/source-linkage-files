skip_on_ci()

test_that("top-level lookup dir works as expected", {
  expect_s3_class(get_lookups_dir(), "fs_path")
  expect_true(fs::dir_exists(get_lookups_dir()))
})

test_that("locality file path returns as expected", {
  expect_s3_class(get_locality_path(), "fs_path")

  expect_equal(fs::path_ext(get_locality_path()), "rds")
  expect_equal(fs::path_ext(get_locality_path(ext = "sav")), "sav")

  expect_match(get_locality_path(), "HSCP Localities_DZ11_Lookup_\\d+?")

  expect_true(fs::file_exists(get_locality_path()))
  expect_true(fs::file_exists(get_locality_path(ext = "sav")))
})

test_that("SPD file path returns as expected", {
  expect_s3_class(get_spd_path(), "fs_path")

  expect_equal(fs::path_ext(get_spd_path()), "rds")
  expect_equal(fs::path_ext(get_spd_path(ext = "zsav")), "zsav")

  expect_match(get_spd_path(), "Scottish_Postcode_Directory_.+?")

  expect_true(fs::file_exists(get_spd_path()))
  expect_true(fs::file_exists(get_spd_path(ext = "zsav")))
})

test_that("SIMD file path returns as expected", {
  expect_s3_class(get_simd_path(), "fs_path")

  expect_equal(fs::path_ext(get_simd_path()), "rds")
  expect_equal(fs::path_ext(get_simd_path(ext = "zsav")), "zsav")

  expect_match(get_simd_path(), "postcode_\\d\\d\\d\\d_\\d_simd\\d\\d\\d\\d.*?")

  expect_true(fs::file_exists(get_simd_path()))
  expect_true(fs::file_exists(get_simd_path(ext = "zsav")))
})

test_that("population estimates file path returns as expected", {
  expect_s3_class(get_datazone_pop_path(), "fs_path")

  expect_equal(fs::path_ext(get_datazone_pop_path()), "rds")
  expect_equal(fs::path_ext(get_datazone_pop_path(ext = "sav")), "sav")

  expect_match(get_datazone_pop_path(), "DataZone2011_pop_est_2001_\\d+?")

  expect_true(fs::file_exists(get_datazone_pop_path()))
  expect_true(fs::file_exists(get_datazone_pop_path(ext = "sav")))
})

test_that("gpprac reference file path returns as expected", {
  expect_s3_class(get_gpprac_ref_path(), "fs_path")

  expect_equal(fs::path_ext(get_gpprac_ref_path()), "sav")

  expect_error(fs::path_ext(get_gpprac_ref_path(ext = "rds")))

  expect_true(fs::file_exists(get_gpprac_ref_path(ext = "sav")))
  expect_true(fs::file_exists(get_gpprac_ref_path()))
})
