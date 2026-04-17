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
# Set up logger and system environment variable BYOC_MODE
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

## Set up run_id and run_date_time ----
# run_id <- Sys.getenv("run_id")
# run_date_time <- Sys.getenv("run_date_time")
run_date_time <- script_run_time

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
# years <- createslf::years_to_run()
year = "1920"

## Build BYOC Output File Paths ----
byoc_output_files <- get_byoc_output_files(
  year,
  types = c("maternity", "mh")
)
# using homelessness for test purpose. When development is complete,
# we change to "types = "byoc_input_files""
# can always use any other type for testing also

# targets ----
logger::log_info("Targets started.")
targets::tar_make(
  script = "SDL_process/dummy_targets.R",
  store = store_path,
  reporter = "timestamp"
)
logger::log_info("Targets finished.")

# Episode file ----

# Individual file ----

logger::log_info("Run SDL ended.")
