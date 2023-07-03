test_that("Free Text is Cleaned Up", {
  names <- c(
    "glasgow care home.",
    " edinburgh Nursing_home",
    "PERTH Residential ",
    "  Dunkeld view   -   house"
  )

  expect_equal(
    clean_up_free_text(names, case_to = "title", remove_punct = TRUE),
    c(
      "Glasgow Care Home",
      "Edinburgh Nursing Home",
      "Perth Residential",
      "Dunkeld View House"
    )
  )
})
