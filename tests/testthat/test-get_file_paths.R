test_that("main SLF directory exists", {
  slf_dir_path <- get_slf_dir()

  expect_true(fs::dir_exists(slf_dir_path))
})
