test_that("Records are flagged correctly", {
  test_frame <- tibble::tribble(
    ~postcode, ~gpprac,
    # Scottish resident
    "AB1 1AA", 18574,
    # Dummy postcode and missing gpprac
    "BF010AA", NA,
    # Dummy postcode and missing gpprac (2)
    "ZZ014AA", NA,
    # Missing postcode and missing gpprac
    NA, NA,
    # Not English practice and missing postcode
    NA, 18574,
    # Not English practice and dummy postcode
    "NF1 1AB", 18574,
    # English postcode and English gpprac
    "BS4 4RG", 99942
  )

  test_frame_flagged <- flag_non_scottish_residents(test_frame)

  expect_equal(
    test_frame_flagged$keep_flag,
    c(0, 2, 2, 2, 3, 4, 1)
  )
})
