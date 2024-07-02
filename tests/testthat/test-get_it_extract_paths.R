test_that("IT reference cleanup works", {
  expect_equal(check_it_reference("SCTASK0439133"), "0439133")
  expect_equal(check_it_reference("0439133"), "0439133")

  expect_error(
    check_it_reference("123456789"),
    "`it_reference` must be exactly 7 numbers\\."
  )
  expect_error(
    check_it_reference("1234567890"),
    "`it_reference` must be exactly 7 numbers\\."
  )
  expect_error(
    check_it_reference("SCTASK123456789"),
    "`it_reference` must be exactly 7 numbers\\."
  )
  expect_error(
    check_it_reference("ABCDEF123456789"),
    "`it_reference` must be exactly 7 numbers\\."
  )
})

skip_on_ci()

test_that("IT extract file paths work", {
  suppressMessages({
    expect_s3_class(get_it_ltc_path(), "fs_path")
    expect_s3_class(get_it_deaths_path(), "fs_path")
    expect_s3_class(get_it_prescribing_path("1920"), "fs_path")
  })

  expect_error(
    get_it_prescribing_path("1111")
  )

  # # Older IT extracts
  # expect_s3_class(
  #   get_it_prescribing_path("1213",
  #     it_reference = "0182748"
  #   ),
  #   "fs_path"
  # )
  # expect_s3_class(
  #   get_it_prescribing_path("1314",
  #     it_reference = "0182748"
  #   ),
  #   "fs_path"
  # )
  # expect_s3_class(
  #   get_it_prescribing_path("1415",
  #     it_reference = "0182748"
  #   ),
  #   "fs_path"
  # )
  expect_error(
    get_it_prescribing_path("1415",
      it_reference = "0000000"
    )
  )
})
