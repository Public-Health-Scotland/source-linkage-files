test_that("main SLF directory exists", {
  slf_dir_path <- get_slf_dir()

  expect_true(fs::dir_exists(slf_dir_path))
})


test_that("Cohorts paths work", {
  expect_s3_class(get_demog_cohorts_path("1920"), "fs_path")
  expect_s3_class(get_service_use_cohorts_path("1920"), "fs_path")
})



test_that("CH costs lookup returns data", {
  ch_cost_lookup <- read_costs_dir("CH")

  names <- c("Year", "nursing_care_provision", "cost_per_day")

  expect_s3_class(ch_cost_lookup, "tbl_df")
  expect_length(ch_cost_lookup, 3)
  expect_named(ch_cost_lookup, names)
})


test_that("DN costs lookup returns data", {
  dn_cost_lookup <- read_costs_dir("DN")

  names <- c("Year", "hbtreatcode", "hbtreatname", "cost_total_net")

  expect_s3_class(dn_cost_lookup, "tbl_df")
  expect_length(dn_cost_lookup, 4)
  expect_named(dn_cost_lookup, names)
})


test_that("GPOoH costs lookup returns data", {
  gpooh_cost_lookup <- read_costs_dir("GPOOH")

  names <- c("Year", "TreatmentNHSBoardCode", "cost_per_consultation")

  expect_s3_class(gpooh_cost_lookup, "tbl_df")
  expect_length(gpooh_cost_lookup, 3)
  expect_named(gpooh_cost_lookup, names)
})


test_that("Deaths file returns data", {
  deaths_file <- read_deaths_dir(n_max = 100)

  expect_s3_class(deaths_file, "tbl_df")
  expect_length(deaths_file, 4)
})
