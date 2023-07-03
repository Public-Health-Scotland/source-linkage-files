test_that("Can convert ca code to lca code", {
  ca <- c(
    "S12000033",
    "S12000049",
    "S12000048",
    NA,
    "S12345678"
  )

  expect_equal(
    convert_ca_to_lca(ca),
    c(
      "01",
      "17",
      "25",
      NA,
      NA
    )
  )
})
