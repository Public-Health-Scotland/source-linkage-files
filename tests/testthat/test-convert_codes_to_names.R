test_that("Can convert HSCP code to HSCP Name", {
  hscp <- c(
    "S37000001",
    "S37000034",
    "S37000033",
    NA,
    "S12345678"
  )

  expect_equal(
    hscp_to_hscpnames(hscp),
    c(
      "Aberdeen City",
      "Glasgow City",
      "Perth and Kinross",
      NA,
      NA
    )
  )
})



test_that("Can convert Health Board code to HB Name", {
  hb <- c(
    "S08000015",
    "S08000031",
    "S08000030",
    NA,
    "S12345678"
  )

  expect_equal(
    hb_to_hbnames(hb),
    c(
      "Ayrshire and Arran",
      "Greater Glasgow and Clyde",
      "Tayside",
      NA,
      NA
    )
  )
})
