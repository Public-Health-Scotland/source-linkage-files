test_that("HHG file path works", {
  expect_s3_class(get_hhg_path("1920"), "fs_path")

  expect_error(get_hhg_path(), "\"year\" is missing, with no default")
  expect_error(
    get_hhg_path("1920", ext = "rds"),
    "The file HHG-201920.rds does not exist in /conf/hscdiip/SLF_Extracts/HHG"
  )
})


test_that("SPARRA file path works", {
  expect_s3_class(get_sparra_path("1920"), "fs_path")

  expect_error(get_sparra_path(), "\"year\" is missing, with no default")
  expect_error(
    get_sparra_path("1920", ext = "rds"),
    "The file SPARRA-201920.rds does not exist in /conf/hscdiip/SLF_Extracts/SPARRA"
  )
})
