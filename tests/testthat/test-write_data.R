dummy_data <- tibble(
  chr = sample(LETTERS, 100, replace = TRUE),
  int = sample(0:9, 100, replace = TRUE),
  num = runif(100)
)

test_that("write_sav creates a file with the correct permissions", {
  temp_path <- tempfile()
  write_sav(dummy_data, temp_path)

  file_info <- fs::file_info(temp_path)
  read_data <- haven::read_sav(temp_path)

  # Check data is the same
  expect_equal(haven::zap_formats(read_data), dummy_data)

  # Check the permissions are as expected
  expect_match(
    as.character(file_info$permissions),
    "rw\\-rw\\-\\-\\-\\-"
  )
})

test_that("write_rds creates a file with the correct permissions", {
  temp_path <- tempfile()
  write_rds(dummy_data, temp_path)

  file_info <- fs::file_info(temp_path)
  read_data <- readr::read_rds(temp_path)

  # Check data is the same
  expect_equal(read_data, dummy_data)

  # Check the permissions are as expected
  expect_match(
    as.character(file_info$permissions),
    "rw\\-rw\\-\\-\\-\\-"
  )
})
