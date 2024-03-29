test_that("Errors properly", {
  expect_error(
    get_file_path(directory = "foo", file_name = "bar"),
    "The directory .+? does not exist\\."
  )

  expect_error(
    get_file_path(
      directory = ".",
      file_name_regexp = "targets",
      check_mode = "write"
    ),
    "`check_mode = \"write\"` can't be used"
  )
})

test_that("Can do check exists", {
  expect_false(get_file_path(
    directory = ".",
    file_name = "foo.R",
    check_mode = "exists"
  ))
})


skip_on_ci()

slf_updates_dir <- fs::path(
  "/",
  "conf",
  "sourcedev",
  "Source_Linkage_File_Updates"
)

test_that("main SLF directory exists", {
  slf_dir_path <- get_slf_dir()

  expect_true(fs::dir_exists(slf_dir_path))
})

test_that("Can return the top level year directory", {
  # Base dir must exist
  expect_true(fs::dir_exists(slf_updates_dir))

  expect_equal(
    get_year_dir("1112"),
    fs::path(slf_updates_dir, "1112")
  )
  expect_equal(
    get_year_dir("1920"),
    fs::path(slf_updates_dir, "1920")
  )
  expect_equal(
    get_year_dir("2122"),
    fs::path(slf_updates_dir, "2122")
  )
})

test_that("Can return the extracts sub-directory of the year dir", {
  expect_equal(
    get_year_dir("1112", extracts_dir = TRUE),
    fs::path(slf_updates_dir, "1112", "Extracts")
  )
  expect_equal(
    get_year_dir("1920", extracts_dir = TRUE),
    fs::path(slf_updates_dir, "1920", "Extracts")
  )
  expect_equal(
    get_year_dir("2122", extracts_dir = TRUE),
    fs::path(slf_updates_dir, "2122", "Extracts")
  )
})

test_that("Will correctly create new directories if needed", {
  test_year_dir <- fs::path(slf_updates_dir, "0000")

  test_year_dir_extracts <- fs::path(test_year_dir, "Extracts")

  # Folders need to not exist for the tests to make sense
  expect_false(fs::dir_exists(test_year_dir))
  expect_false(fs::dir_exists(test_year_dir_extracts))

  expect_message(
    get_year_dir("0000"),
    " did not exist, it has now been created\\."
  )
  expect_true(fs::dir_exists(test_year_dir))

  expect_message(
    get_year_dir("0000", extracts_dir = TRUE),
    " did not exist, it has now been created\\."
  )
  expect_true(fs::dir_exists(test_year_dir_extracts))

  # Clean up
  fs::dir_delete(test_year_dir)
})
