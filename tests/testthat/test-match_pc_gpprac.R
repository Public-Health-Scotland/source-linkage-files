test_that("Health Board codes are recoded properly", {
  # Single code
  expect_equal(
    recode_health_boards("S08000018"),
    "S08000029"
  )

  # Vector of codes
  expect_equal(
    recode_health_boards(c("S08000018", "S08000031", "S08000032", "S08000027", "S08000001")),
    c("S08000029", "S08000021", "S08000023", "S08000030", "S08000001")
  )
})

test_that("HSCP codes are recoded properly", {
  # Single code
  expect_equal(
    recode_hscp("S37000014"),
    "S37000032"
  )

  # Vector of codes
  expect_equal(
    recode_hscp(c("S37000023", "S37000034", "S37000035", "S37000014", "S37000002")),
    c("S37000033", "S37000015", "S37000021", "S37000032", "S37000002")
  )
})

test_that("Geographies are renamed correctly", {
  # Expected variables
  dummy <- tibble::tribble(~lca, ~HSCP, ~DataZone, ~hbrescode)
  expect_equal(
    colnames(rename_existing_geographies(dummy)),
    c("lca_old", "HSCP_old", "DataZone_old", "hbrescode_old")
  )

  # Custom variables
  dummy <- tibble::tribble(~one, ~two, ~three)
  expect_equal(
    colnames(rename_existing_geographies(dummy, c("one", "two", "three"))),
    c("one_old", "two_old", "three_old")
  )

  # Some variables but not others
  dummy <- tibble::tribble(~lca, ~HSCP, ~DataZone, ~dummy_one, ~hbrescode, ~dummy_two)
  expect_equal(
    colnames(rename_existing_geographies(dummy)),
    c("lca_old", "HSCP_old", "DataZone_old", "dummy_one", "hbrescode_old", "dummy_two")
  )

  # Error
  dummy <- tibble::tribble(~lca, ~HSCP, ~DataZone)
  expect_error(colnames(rename_existing_geographies(dummy)))
})
