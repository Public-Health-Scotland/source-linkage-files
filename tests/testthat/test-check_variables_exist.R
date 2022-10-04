test_that("check_variables_exist accepts proper input", {
  expect_true(check_variables_exist(tibble(a = 1:3), "a"))
  expect_true(check_variables_exist(tibble(a = 1:26, b = letters), "a"))
  expect_true(check_variables_exist(tibble(a = 1:26, b = letters), c("a", "b")))

  expect_error(
    check_variables_exist(tibble(a = 1:26, b = letters), a),
    "object 'a' not found"
  )
  expect_error(
    check_variables_exist(tibble(a = 1:26, b = letters), 1),
    "`variables` must be a .+?character.+? not a .+?numeric.+?\\."
  )
  expect_error(
    check_variables_exist("a", "a"),
    "`data` must be a .+?tbl_df.+? not a .+?character.+?\\."
  )
})

test_that("check_variables_exist throws informative errors", {
  test_data <- tibble(
    a = 1:26,
    b = letters,
    c = LETTERS
  )

  expect_snapshot_error(check_variables_exist(test_data, "d"))
  expect_snapshot_error(check_variables_exist(test_data, c("a", "b", "d")))
  expect_snapshot_error(check_variables_exist(
    test_data,
    c("a", "b", "d", "e")
  ))



  expect_snapshot_error(check_variables_exist(
    dplyr::starwars,
    c("name", "height", "recid", "smrtype", "mpat")
  ))
})
