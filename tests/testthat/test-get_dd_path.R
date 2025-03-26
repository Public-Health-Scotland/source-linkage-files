skip_on_ci()

test_that("Delayed discharges file exists", {
  latest_dd_path <- get_dd_path()

  expect_s3_class(latest_dd_path, "fs_path")
  expect_equal(fs::path_ext(latest_dd_path), "parquet")
})

test_that("Delayed discharges file is as expected", {
  latest_dd_file <- read_file(get_dd_path())

  n_rows <- nrow(latest_dd_file)

  expect_gt(n_rows, 150000)

  # Expect at least 98% of CHIs to be valid
  expect_gt(
    table(
      phsmethods::chi_check(latest_dd_file %>% slfhelper::get_chi() %>% dplyr::pull(chi))
    )["Valid CHI"],
    0.98 * n_rows
  )
})
