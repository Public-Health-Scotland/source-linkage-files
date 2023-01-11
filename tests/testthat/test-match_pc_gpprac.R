test_that("Health Board codes are recoded properly", {

  # Single code
  expect_equal(
    recode_health_boards("S08000018"),
    "S08000029"
  )

  # Vector of codes
  expect_equal(
    recode_health_boards(c("S08000018", "S08000031", "S08000032", "S08000027", "S08000001")),
    c("S08000029", "S08000021", "S08000023", "S08000030", "S08000001")
  )

})

test_that("HSCP codes are recoded properly", {

  # Single code
  expect_equal(
    recode_hscp("S37000014"),
    "S37000032"
  )

  # Vector of codes
  expect_equal(
    recode_hscp(c("S37000023", "S37000034", "S37000035", "S37000014", "S37000002")),
    c("S37000033", "S37000015", "S37000021", "S37000032", "S37000002")
  )

})
