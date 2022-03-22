test_that("is_missing works", {
  expect_type(check_char_is_missing(c("a", "b", "c")), "logical")

  expect_equal(check_char_is_missing(c("a", "b", "c")), c(FALSE, FALSE, FALSE))
  expect_equal(check_char_is_missing(c("a", "", "c")), c(FALSE, TRUE, FALSE))
  expect_equal(check_char_is_missing(c("a", NA, "c")), c(FALSE, TRUE, FALSE))
  expect_equal(check_char_is_missing(c(NA, NA, "")), c(TRUE, TRUE, TRUE))

  expect_error(check_char_is_missing(c(1, 2, 3)), ", but numeric was supplied")
  expect_error(check_char_is_missing(c(TRUE, FALSE)), ", but logical was supplied")
  expect_error(check_char_is_missing(as.Date(c("2020-01-01", "1990-09-01"))), ", but Date was supplied")
})
