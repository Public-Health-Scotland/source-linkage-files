test_that("Add PPA flag works as expected for various cases", {
  example_data <- tibble::tribble(
    ~chi, ~cij_marker, ~cij_pattype, ~recid, ~op1a, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6,
    # EXPECT cij_ppa = TRUE
    # Case 1, reliant on diag1, first 3 characters
    1L, 1L, "Non-Elective", "02B", "", "E40", "", "", "", "", "",
    # Case 2, relaint on diag1, first four characters
    2L, 1L, "Non-Elective", "01B", "", "K522", "", "", "", "", "",
    # Case 3, reliant on any diagnosis code, first three characters
    3L, 1L, "Non-Elective", "04B", "", "A01", "A35", "", "", "", "",
    4L, 1L, "Non-Elective", "GLS", "", "", "", "", "R02", "", "",
    # Case 4, reliant on any diagnosis code, first four characters
    1L, 2L, "Non-Elective", "01B", "", "A001", "A002", "E113", "", "", "",
    6L, 1L, "Non-Elective", "02B", "", "A001", "A002", "A003", "A004", "J181", "",
    # Case 5, reliant on op1a and diag1
    7L, 1L, "Non-Elective", "04B", "L21", "I20", "", "", "", "", "",
    # Case 6, reliant on diag1 and diag2
    8L, 1L, "Non-Elective", "GLS", "", "J20", "J41", "", "", "", "",
    # EXPECT cij_ppa = FALSE
    # Case 7, elective admission
    2L, 2L, "Elective", "01B", "", "G40", "", "", "", "", "",
    # Case 8, right diag1 but excluded op1a
    1L, 3L, "Non-Elective", "01B", "K02", "I50", "", "", "", "", "",
    # Case 9, wrong diag1
    11L, 1L, "Non-Elective", "02B", "", "A01", "", "", "", "", "",
    # Multi-episode example, all should be PPA as the first is
    12L, 1L, "Non-Elective", "02B", "", "E43", "", "", "", "", "",
    12L, 1L, "Non-Elective", "02B", "", "", "", "", "", "", "",
    12L, 1L, "Non-Elective", "02B", "", "", "", "", "", "", "",
    # Multi-episode example, first is not PPA so neither are the next two
    13L, 1L, "Non-Elective", "02B", "", "", "", "", "", "", "",
    13L, 1L, "Non-Elective", "02B", "", "K251", "", "", "", "", "",
    13L, 1L, "Non-Elective", "02B", "", "", "", "", "", "", ""
  )

  example_data_ppa <- add_ppa_flag(example_data)

  expect_equal(example_data_ppa$cij_ppa, c(
    TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
    FALSE, FALSE, FALSE,
    TRUE, TRUE, TRUE,
    FALSE, FALSE, FALSE
  ))
})

test_that("Errors are handled as expected", {
  # Wrong columns
  error_data <- tibble::tribble(
    ~chi, ~recid, ~diag1, ~something_silly,
    1L, "01B", "A01", "Foo"
  )
  expect_error(
    add_ppa_flag(error_data),
    "Variables .+ are required, but are missing from \`data\`"
  )

  # Wrong recids
  error_data_2 <- tibble::tribble(
    ~chi, ~cij_marker, ~cij_pattype, ~recid, ~op1a, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6,
    1L, 1L, "Non-Elective", "Wrong", "", "", "", "", "", "", "",
    2L, 1L, "Non-Elective", "Wronger", "", "", "", "", "", "", "",
    3L, 1L, "Non-Elective", "Wrongest", "", "", "", "", "", "", ""
  )
  expect_error(
    add_ppa_flag(error_data_2),
    "None of the 3 recids provided will relate to PPAs, and the function will abort."
  )
})
