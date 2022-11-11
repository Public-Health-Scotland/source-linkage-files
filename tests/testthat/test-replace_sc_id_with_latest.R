test_that("Replace sc id with the latest works for various cases", {
  dummy_data <- tibble::tribble(
    ~sending_location, ~social_care_id, ~chi, ~period,
    # Case where sc id changes
    # should be replaced with the latest
    001, 000001, 0000000001, "2018Q1",
    001, 000001, 0000000001, "2018Q2",
    001, 000011, 0000000001, "2018Q3",
    001, 000011, 0000000001, "2018Q4",
    # Case where sc id changes to 22 then back to 02
    # should be replaced with the latest
    002, 000002, 0000000002, "2019Q1",
    002, 000022, 0000000002, "2019Q2",
    002, 000002, 0000000002, "2019Q3",
    002, 000022, 0000000002, "2019Q4",
    # Case where sc id should not be replaced
    003, 000003, 0000000003, "2017Q1",
    003, 000003, 0000000003, "2017Q2",
    003, 000003, 0000000003, "2017Q3",
    # CHI is missing but sc id changes
    # should not be replaced
    004, 000004, NA, "2017Q1",
    004, 000044, NA, "2017Q2",
    004, 000044, NA, "2017Q3",
    # Case where sc id changes in Q2 but CHI is missing
    # should not be replaced
    005, 000005, NA, "2018Q1",
    005, 000055, NA, "2018Q2",
    005, 000005, NA, "2018Q3"
  )

  changed_dummy_data <- replace_sc_id_with_latest(dummy_data)

  expect_equal(changed_dummy_data, tibble::tribble(
    ~sending_location, ~latest_sc_id, ~chi, ~social_care_id, ~period,
    # Case where sc id changes
    # should be replaced with the latest
    001, 000011, 0000000001, 000011, "2018Q1",
    001, 000011, 0000000001, 000011, "2018Q2",
    001, 000011, 0000000001, 000011, "2018Q3",
    001, 000011, 0000000001, 000011, "2018Q4",
    # Case where sc id changes to 22 then back to 02
    # should be replaced with the latest
    002, 000022, 0000000002, 000022, "2019Q1",
    002, 000022, 0000000002, 000022, "2019Q2",
    002, 000022, 0000000002, 000022, "2019Q3",
    002, 000022, 0000000002, 000022, "2019Q4",
    # Case where sc id should not be replaced
    003, 000003, 0000000003, 000003, "2017Q1",
    003, 000003, 0000000003, 000003, "2017Q2",
    003, 000003, 0000000003, 000003, "2017Q3",
    # CHI is missing but sc id changes
    # should not be replaced
    004, 000044, NA, 000004, "2017Q1",
    004, 000044, NA, 000044, "2017Q2",
    004, 000044, NA, 000044, "2017Q3",
    # Case where sc id changes in Q2 but CHI is missing
    # should not be replaced
    005, 000005, NA, 000005, "2018Q1",
    005, 000005, NA, 000055, "2018Q2",
    005, 000005, NA, 000005, "2018Q3"
  ))
})
