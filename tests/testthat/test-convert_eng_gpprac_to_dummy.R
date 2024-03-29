test_that("GP English dummy code function returns data", {
  # Check types
  expect_type(convert_eng_gpprac_to_dummy(c("1234", "A1235")), "integer")
  expect_length(convert_eng_gpprac_to_dummy(c("1234", "A1235")), 2L)

  # Check contents
  expect_equal(convert_eng_gpprac_to_dummy(c("1234", "A1235")), c(1234L, 9995L))
  expect_equal(
    convert_eng_gpprac_to_dummy(c("1234", "A1235", NA_character_)),
    c(1234L, 9995L, NA_integer_)
  )
})
