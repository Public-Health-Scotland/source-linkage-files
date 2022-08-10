skip_on_ci()

test_that("GP clusters file (Practice Details) path works", {
  expect_s3_class(get_practice_details_path(ext = "zsav"), "fs_path")
  expect_s3_class(get_practice_details_path(), "fs_path")

  expect_equal(fs::path_ext(get_practice_details_path()), "rds")

  expect_match(get_practice_details_path(), glue::glue("practice_details_{latest_update()}"))
})
