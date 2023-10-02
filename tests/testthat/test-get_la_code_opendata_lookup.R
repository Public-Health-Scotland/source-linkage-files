skip_if_offline()

test_that("LA Code lookup is correct", {
  la_code_lookup <- get_la_code_opendata_lookup()

  expect_s3_class(la_code_lookup, "tbl_df")
  expect_named(
    la_code_lookup,
    c("CA", "CAName", "sending_local_authority_name")
  )

  expect_snapshot(get_la_code_opendata_lookup())
})
