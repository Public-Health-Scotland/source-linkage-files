test_that("SC demographic file path works", {
  expect_s3_class(get_sc_demog_lookup_path(), "fs_path")
  expect_s3_class(
    get_sc_demog_lookup_path(
      update = previous_update()
    ),
    "fs_path"
  )
})
