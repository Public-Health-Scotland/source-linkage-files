# run_sdl.R for testing

# First step rename current dataset so it is not overwritten.####
# will need to change/remove renaming step once switched to seer

# 00 setup logger ----
logger::log_info("Run SDL starts.")

## create dummy acute data ----
logger::log_info("Create dummy acute data now.")
set.seed(123)
n <- 100
sdl_result_df <- data.frame(
  id = rep(1, n),
  year = rep("2425", n),
  recid = "01B",
  record_keydate1 = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  record_keydate2 = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  smrtype = sample(c("SMR01", "SMR00"), n, TRUE),
  anon_chi = sprintf(
    "%010s",
    paste0(
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE),
      sample(0:9, n, replace = TRUE)
    )
  ),
  gender = sample(c("M", "F", "U"), n, TRUE),
  dob = as.Date("1930-01-01") + sample(0:30000, n, TRUE),
  gpprac = sample(sprintf("G%04d", 1:9999), n, TRUE),
  hbpraccode = sample(sprintf("HB%02d", 1:20), n, TRUE),
  postcode = sample(c("EH1 1AA", "G1 2FF", "AB10 1AB", "DD1 4HN", "FK8 2ET"), n, TRUE),
  hbrescode = sample(sprintf("HB%02d", 1:20), n, TRUE),
  lca = sample(sprintf("LCA%02d", 1:32), n, TRUE),
  hscp = sample(sprintf("HSCP%02d", 1:31), n, TRUE),
  location = sample(c("HOME", "HOSP", "CAREHOME"), n, TRUE),
  hbtreatcode = sample(sprintf("HB%02d", 1:20), n, TRUE),
  yearstay = sample(2015:2025, n, TRUE),
  stay = sample(1:10, n, TRUE),
  ipdc = sample(c("I", "D", "C"), n, TRUE),
  spec = sample(100:999, n, TRUE),
  sigfac = sample(0:1, n, TRUE),
  conc = sample(0:1, n, TRUE),
  mpat = sample(c("NHS", "Private"), n, TRUE),
  cat = rep(NA, n),
  tadm = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  adtf = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  admloc = sample(c("A&E", "GP", "Clinic", "Transfer"), n, TRUE),
  oldtadm = as.Date("2010-01-01") + sample(0:5500, n, TRUE),
  disch = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  dischto = sample(c("Home", "Care home", "Other hospital", "Died"), n, TRUE),
  dischloc = sample(c("Ward", "ICU", "Community"), n, TRUE),
  diag1 = sample(sprintf("I%02d", 1:99), n, TRUE),
  diag2 = sample(c(sprintf("J%02d", 1:99), NA), n, TRUE),
  diag3 = sample(c(sprintf("E%02d", 1:99), NA), n, TRUE),
  diag4 = sample(c(sprintf("K%02d", 1:99), NA), n, TRUE),
  diag5 = sample(c(sprintf("C%02d", 1:99), NA), n, TRUE),
  diag6 = sample(c(sprintf("F%02d", 1:99), NA), n, TRUE),
  op1a = sample(c(sprintf("A%03d", 1:999), NA), n, TRUE),
  op1b = sample(c(sprintf("B%03d", 1:999), NA), n, TRUE),
  dateop1 = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  op2a = sample(c(sprintf("A%03d", 1:999), NA), n, TRUE),
  op2b = sample(c(sprintf("B%03d", 1:999), NA), n, TRUE),
  dateop2 = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  op3a = sample(c(sprintf("A%03d", 1:999), NA), n, TRUE),
  op3b = sample(c(sprintf("B%03d", 1:999), NA), n, TRUE),
  dateop3 = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  op4a = sample(c(sprintf("A%03d", 1:999), NA), n, TRUE),
  op4b = sample(c(sprintf("B%03d", 1:999), NA), n, TRUE),
  dateop4 = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  smr01_cis_marker = sample(0:1, n, TRUE),
  age = sample(0:100, n, TRUE),
  cij_marker = sample(0:1, n, TRUE),
  cij_pattype_code = sample(1:5, n, TRUE),
  cij_ipdc = sample(c("I", "D", "C"), n, TRUE),
  cij_admtype = sample(c("Elective", "Emergency"), n, TRUE),
  cij_adm_spec = sample(100:999, n, TRUE),
  cij_dis_spec = sample(100:999, n, TRUE),
  cij_start_date = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  cij_end_date = as.Date("2015-01-01") + sample(0:4000, n, TRUE),
  alcohol_adm = sample(0:1, n, TRUE),
  submis_adm = sample(0:1, n, TRUE),
  falls_adm = sample(0:1, n, TRUE),
  selfharm_adm = sample(0:1, n, TRUE),
  commhosp = sample(0:1, n, TRUE),
  cost_total_net = round(runif(n, 500, 25000), 2),
  apr_beddays = sample(0:30, n, TRUE),
  may_beddays = sample(0:31, n, TRUE),
  jun_beddays = sample(0:30, n, TRUE),
  jul_beddays = sample(0:31, n, TRUE),
  aug_beddays = sample(0:31, n, TRUE),
  sep_beddays = sample(0:30, n, TRUE),
  oct_beddays = sample(0:31, n, TRUE),
  nov_beddays = sample(0:30, n, TRUE),
  dec_beddays = sample(0:31, n, TRUE),
  jan_beddays = sample(0:31, n, TRUE),
  feb_beddays = sample(0:29, n, TRUE),
  mar_beddays = sample(0:31, n, TRUE),
  apr_cost = round(runif(n, 0, 5000), 2),
  may_cost = round(runif(n, 0, 5000), 2),
  jun_cost = round(runif(n, 0, 5000), 2),
  jul_cost = round(runif(n, 0, 5000), 2),
  aug_cost = round(runif(n, 0, 5000), 2),
  sep_cost = round(runif(n, 0, 5000), 2),
  oct_cost = round(runif(n, 0, 5000), 2),
  nov_cost = round(runif(n, 0, 5000), 2),
  dec_cost = round(runif(n, 0, 5000), 2),
  jan_cost = round(runif(n, 0, 5000), 2),
  feb_cost = round(runif(n, 0, 5000), 2),
  mar_cost = round(runif(n, 0, 5000), 2),
  uri = paste0("urn:uuid:", replicate(n, paste(sample(c(0:9, letters), 32, TRUE), collapse = ""))),
  cup_marker = sample(0:1, n, TRUE),
  cup_pathway = sample(c("Elective", "Emergency", "Day case", "Outpatient"), n, TRUE)
)

# save dummy acute data
# output_filepath = "sdl_byoc/byoc/output/sdl_acute.csv.gz"
# write.csv.gz(slipbd_result_df, output_filepath, na = "", row.names = FALSE)
# logger::log_info("Dummy acute data is saved.")


test_query <- "SELECT COUNT(*) FROM sdl.sdl_byoc_data_year_matrix"
query_result <- dbGetQuery(denodo_connection, test_query)

logger::log_info("Print test query result:")
print(query_result)
