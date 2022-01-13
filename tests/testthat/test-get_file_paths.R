test_that("main SLF directory exists", {
  slf_dir_path <- get_slf_dir()

  expect_true(fs::dir_exists(slf_dir_path))
})


test_that("SLF GP practice lookup file paths work", {
  expect_s3_class(get_slf_gpprac_path(), "fs_path")
  expect_s3_class(get_slf_gpprac_path(update = previous_update()), "fs_path")
})


test_that("Demographic file returns data", {
  demographic_file <- read_cohorts_dir("demographic", "1819", n_max = 100)

  var_names <- c(
    "chi", "Demographic_Cohort", "End_of_LIfe", "Frailty", "High_CC",
    "Maternity", "MH", "Substance", "Medium_CC", "Low_CC", "Child_Major",
    "Adult_Major", "Comm_Living"
  )

  expect_s3_class(demographic_file, "tbl_df")
  expect_length(demographic_file, 13)
  expect_named(demographic_file, var_names)
})


test_that("Service Use file returns data", {
  service_use_file <- read_cohorts_dir("service_use", "1819", n_max = 100)

  names <- c(
    "chi", "Service_Use_Cohort", "Psychiatry_Cost", "Maternity_Cost", "Geriatric_Cost",
    "Elective_Inpatient_Cost", "Limited_Daycases_Cost", "Single_Emergency_Cost",
    "Multiple_Emergency_Cost", "Routine_Daycase_Cost", "Outpatient_Cost",
    "Prescribing_Cost", "AE2_Cost"
  )

  expect_s3_class(service_use_file, "tbl_df")
  expect_length(service_use_file, 13)
  expect_named(service_use_file, names)
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
