skip_on_ci()

test_that("main SLF directory exists", {
  slf_dir_path <- get_slf_dir()

  expect_true(fs::dir_exists(slf_dir_path))
})


test_that("get_year_dir works", {

  # Base dir must exist
  expect_true(fs::dir_exists("/conf/sourcedev/Source_Linkage_File_Updates"))

  expect_equal(
    get_year_dir("1112"),
    fs::path("/conf/sourcedev/Source_Linkage_File_Updates", "1112")
  )
  expect_equal(
    get_year_dir("1920"),
    fs::path("/conf/sourcedev/Source_Linkage_File_Updates", "1920")
  )
  expect_equal(
    get_year_dir("2122"),
    fs::path("/conf/sourcedev/Source_Linkage_File_Updates", "2122")
  )

  expect_equal(
    get_year_dir("1112", extracts_dir = TRUE),
    fs::path("/conf/sourcedev/Source_Linkage_File_Updates", "1112", "Extracts")
  )
  expect_equal(
    get_year_dir("1920", extracts_dir = TRUE),
    fs::path("/conf/sourcedev/Source_Linkage_File_Updates", "1920", "Extracts")
  )
  expect_equal(
    get_year_dir("2122", extracts_dir = TRUE),
    fs::path("/conf/sourcedev/Source_Linkage_File_Updates", "2122", "Extracts")
  )
})
