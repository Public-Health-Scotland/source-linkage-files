# run_sdl.R

# Setup ----
logger::log_info("Run SDL starts.")

library(createslf)
library(DBI)
library(arrow)
library(data.table)
library(dbplyr)
library(dplyr)
library(fs)
library(hms)
library(janitor)
library(keyring)
library(lubridate)
library(magrittr)
library(odbc)
library(openxlsx)
library(phsmethods)
library(phsopendata)
library(purrr)
library(readr)
library(rlang)
library(rmarkdown)
library(readxl)
library(rstudioapi)
library(slfhelper)
library(stringdist)
library(stringr)
library(tibble)
library(tidyr)
library(tidyselect)
library(zoo)
library(knitr)
library(roxygen2)
library(scales)
library(spelling)
library(tarchetypes)
library(targets)
library(testthat)
library(crew)

## Detect BYOC_MODE ----
BYOC_MODE <- Sys.getenv("BYOC_MODE")
if (tolower(BYOC_MODE) %in% c("true", "t")) {
  logger::log_info("Detect run_sdl.r run on Denodo")
  BYOC_MODE <- TRUE
} else {
  logger::log_info("Detect run_sdl.r run locally")
  BYOC_MODE <- FALSE
}

## Set up targets store path ----
store_path <- dplyr::if_else(
  BYOC_MODE,
  "/sdl_byoc/_targets",
  "/conf/sourcedev/Source_Linkage_File_Updates/_targets"
)

## Load Control Sheets ----
# TODO: Check whether we should make a new connection in BYOC mode
if (isFALSE(BYOC_MODE)) {
  denodo_connect <- createslf::get_denodo_connection(BYOC_MODE = BYOC_MODE)
}

# Data Control Sheet
data_control_sheet <- dplyr::tbl(
  denodo_connect,
  dbplyr::in_schema("sdl", "sdl_byoc_data_control_sheet")
) %>%
  dplyr::collect()

# Snapshot Control Sheet
snapshot_control_sheet <- dplyr::tbl(
  denodo_connect,
  dbplyr::in_schema("sdl", "sdl_byoc_snapshot_control_sheet")
) %>%
  dplyr::collect()

# Test Control Sheet
test_control_sheet <- dplyr::tbl(
  denodo_connect,
  dbplyr::in_schema("sdl", "sdl_byoc_test_control_sheet")
) %>%
  dplyr::collect()

# Linkage Control Sheet
linkage_control_sheet <- dplyr::tbl(
  denodo_connect,
  dbplyr::in_schema("sdl", "sdl_byoc_linkage_control_sheet")
) %>%
  dplyr::collect()

if (isFALSE(BYOC_MODE)) {
  odbc::dbDisconnect(denodo_connect)
}

# Make sure there it only one run in the data control sheet
data_control_sheet <- data_control_sheet %>%
  dplyr::filter(date_of_request == min(data_control_sheet$date_of_request))

# Pull PHS run ID
phs_run_id <- data_control_sheet$phs_run_id

# Pull reporting period & set as environment variable
reporting_period <- data_control_sheet$reporting_period
Sys.setenv(reporting_period = reporting_period)

# Pull snapshots
snapshot_ids <- strsplit(data_control_sheet$snapshot_ids, ",")[[1]]

# Pull years included in snapshots
fys <- snapshot_control_sheet %>%
  dplyr::filter(snapshot_id %in% snapshot_ids) %>%
  stats::na.omit() %>%
  dplyr::pull(fys) %>%
  paste(collapse = ",") %>%
  strsplit(",") %>%
  unlist() %>%
  stringr::str_trim() %>%
  unique()

# If NA, snapshot includes all years (2014/15 to current)
if (length(fys) == 0) {
  end_year <- as.integer(
    stringr::str_sub(
      phsmethods::extract_fin_year(end_date()),
      3, 4
    )
  )
  fys <- paste0(14:end_year, 15:(end_year + 1))
}

# Get benchmarks for tests
test_control_sheet <- test_control_sheet %>%
  filter(assessment_run_id == phs_run_id)

benchmark_run_id <- test_control_sheet$benchmark_run_id
benchmark_comparison_type <- test_control_sheet$test_type

# Set fys as environment variable
Sys.setenv(
  fys = paste(fys, collapse = ","),
  benchmark_run_id = benchmark_run_id,
  benchmark_comparison_type = benchmark_comparison_type
)

## Include reporting of last run date of ACADME ----
if (isFALSE(BYOC_MODE)) {
  denodo_connect <- createslf::get_denodo_connection(BYOC_MODE = BYOC_MODE)
}

dplyr::tbl(
  denodo_connect,
  dbplyr::in_schema("sdl", "sdl_byoc_acadme_load_detail")
) %>%
  dplyr::collect() %>%
  # Optional: Format the date to look clean first
  dplyr::mutate(load_str = format(load_date, "%Y-%m-%d %H:%M:%S")) %>%
  purrr::pwalk(function(data_mart, load_str, ...) {
    logger::log_info("{data_mart} loaded at {load_str}")
  })
if (isFALSE(BYOC_MODE)) {
  odbc::dbDisconnect(denodo_connect)
}

## Set up years to run ----
years <- createslf::years_to_run()

## Build BYOC Output File Paths ----
# When development is complete change to `types = "byoc_input_files"`
byoc_output_files <- get_byoc_output_files(
  years,
  types = c(
    # BOXI
    "acute",
    "ae",
    "gp_ooh",
    "homelessness",
    "maternity",
    "mh",
    "nrs_deaths",
    "outpatients",

    # Files
    "cmh",
    "dd",
    "dn",
    # "hhg",
    # "sparra",

    # Social Care
    "at",
    "ch",
    "client",
    "hc",
    "sds",
    "sc_all_at",
    "sc_all_ch",
    "sc_all_hc",
    "sc_all_sds",
    "sc_demog_lookup",

    # IT
    "chi_deaths",
    "ltc",
    "pis",

    # Costs
    "ch_cost_lookup",
    "dn_cost_lookup",
    "hc_cost_lookup",
    "ooh_cost_lookup",

    # Look-ups
    "combined_deaths",
    "gpprac_lookup",
    "homelessness_completeness",
    "postcode_lookup"
    # "demog_c",
    # "service_c"
  )
)

# targets ----
logger::log_info("Targets started.")

tryCatch(
  log_tar_make(
    script = "SDL_process/dummy_targets.R",
    store = store_path,
    reporter = "verbose"
  ),
  error = function(e) {
    logger::log_error("Targets failed: {conditionMessage(e)}")
    stop(e)
  }
)
logger::log_info("Targets finished.")

logger::log_info("Run SDL ended.")
