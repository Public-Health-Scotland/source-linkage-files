test_that("main SLF directory exists", {
  slf_dir_path <- get_slf_dir()

  expect_true(fs::dir_exists(slf_dir_path))
})

test_that("Delayed discharges path works", {
  expect_s3_class(get_dd_path(), "fs_path")
  expect_error(get_dd_path(ext = "rds"))
})


test_that("gpprac lookup returns data", {
  gpprac_lookup <- read_lookups_dir("gpprac")

  var_names <- c("gpprac", "pc7", "PC8", "cluster", "hbpraccode", "HSCP2018", "CA2018", "LCA")

  expect_s3_class(gpprac_lookup, "tbl_df")
  expect_length(gpprac_lookup, 8)
  expect_named(gpprac_lookup, var_names)
})



test_that("Postcode lookup returns data", {
  postcode_lookup <- read_lookups_dir("postcode")

  var_names <- c(
    "postcode", "HB2018", "HSCP2018", "CA2018", "LCA", "Locality", "DataZone2011",
    "HB2019", "CA2019", "HSCP2019", "SIMD2020v2_rank", "simd2020v2_sc_decile", "simd2020v2_sc_quintile",
    "simd2020v2_hb2019_decile", "simd2020v2_hb2019_quintile", "simd2020v2_hscp2019_decile",
    "simd2020v2_hscp2019_quintile", "UR8_2016", "UR6_2016", "UR3_2016", "UR2_2016"
  )

  expect_s3_class(postcode_lookup, "tbl_df")
  expect_length(postcode_lookup, 21)
  expect_named(postcode_lookup, var_names)
})


test_that("GP clusters file (Practice Details) path works", {
  expect_s3_class(get_practice_details_path(), "fs_path")
  expect_error(get_practice_details_path(ext = "rds"))
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


test_that("HHG extract returns data", {
  hhg_file <- read_hhg_dir("1819", n_max = 100)

  expect_s3_class(hhg_file, "tbl_df")
  expect_length(hhg_file, 2)
})


test_that("SPARRA file path works", {
  expect_s3_class(get_sparra_path("1920"), "fs_path")

  expect_error(get_sparra_path(), "\"year\" is missing, with no default")
  expect_error(
    get_sparra_path("1920", ext = "rds"),
    "The file SPARRA-201920.rds does not exist in /conf/hscdiip/SLF_Extracts/SPARRA"
  )
})


test_that("NSU file path works", {
  expect_s3_class(get_nsu_path(year = "1920"), "fs_path")
  expect_error(get_nsu_path(year = "1920", ext = "rds"))
})


test_that("IT extract file paths work", {
  expect_s3_class(get_it_ltc_path(), "fs_path")
  expect_s3_class(get_it_deaths_path(), "fs_path")
  expect_s3_class(get_it_prescribing_path("1920"), "fs_path")
})
