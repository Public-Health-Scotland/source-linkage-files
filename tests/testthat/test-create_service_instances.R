test_that("Flags are assigned correctly", {
  dummy_data <- tibble::tribble(
    ~cij_marker, ~cij_pattype, ~cij_ipdc, ~cost_total_net,
    "01B", "Non-Elective", "D", 1,
    "02B", "Elective", "I", 1,
    "04B", "Non-Elective", "I", 1,
    "OoH", "Elective", "D", 1,
    "AE2", "Elective", "", 1,
    "01B", "", "D", 1,
    "NRS", "", "", 1
  )

  test_output <- create_service_instances(dummy_data)

  # Emergency
  expect_equal(
    test_output$emergency_instances,
    c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)
  )

  # Elective
  expect_equal(
    test_output$elective_instances,
    c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE)
  )

  # Elective inpatient
  expect_equal(
    test_output$elective_inpatient_instances,
    c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
  )

  # Elective daycase
  expect_equal(
    test_output$elective_daycase_instances,
    c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE)
  )

  # Death flags
  expect_equal(
    test_output$death_flag,
    c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
  )

  # Elective costs
  expect_equal(
    test_output$elective_inpatient_cost,
    c(0, 1, 0, 0, 0, 0, 0)
  )
})

test_that("Errors handled as expected", {
  expect_error(create_service_instances(tibble::tribble(~cij_marker, ~test_bad)),
    regexp = "Variables .+ are required, but are missing from `data`"
  )
})
