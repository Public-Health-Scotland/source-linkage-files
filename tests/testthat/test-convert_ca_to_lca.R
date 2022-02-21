library(testthat)
test_that("Can convert ca code to lca code", {
  ca <- c(
    "S12000033",
    "S12000049",
    "S12000048"
  )

  expect_equal(
    ca_to_lca(ca),
    c(
      "01",
      "17",
      "25"
    )
  )
})
