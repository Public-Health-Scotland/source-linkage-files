skip_on_ci()

test_that("GP clusters file (Practice Details) file exists", {
  expect_s3_class(get_practice_details_path(), "fs_path")

  expect_match(
    get_practice_details_path(),
    stringr::str_glue("practice_details_{latest_update()}")
  )
})
