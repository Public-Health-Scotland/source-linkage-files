skip_on_ci()

test_that("IT extract file paths work", {
  expect_s3_class(get_it_ltc_path(), "fs_path")
  expect_s3_class(get_it_deaths_path(), "fs_path")
  expect_s3_class(get_it_prescribing_path("1920"), "fs_path")
  expect_error(
    get_it_prescribing_path("1415"),
    "Unable to find file for 1415 with reference SCTASK\\d{7}"
  )

  # Older IT extracts
  expect_s3_class(
    get_it_prescribing_path("1213",
      it_reference = "SCTASK0182748"
    ),
    "fs_path"
  )
  expect_s3_class(
    get_it_prescribing_path("1314",
      it_reference = "SCTASK0182748"
    ),
    "fs_path"
  )
  expect_s3_class(
    get_it_prescribing_path("1415",
      it_reference = "SCTASK0182748"
    ),
    "fs_path"
  )
  expect_error(
    get_it_prescribing_path("1516",
      it_reference = "SCTASK0182748"
    ),
    "Unable to find file for 1516 with reference SCTASK0182748"
  )
})
