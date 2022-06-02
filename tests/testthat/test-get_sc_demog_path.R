test_that("SC demographic file path works", {
  expect_s3_class(get_sc_demog_lookup_path(ext = "zsav"), "fs_path")
  expect_s3_class(
    get_sc_demog_lookup_path(
      update = previous_update(),
      ext = "zsav"
    ),
    "fs_path"
  )
})
