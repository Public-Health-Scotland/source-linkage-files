# run_sdl.R for testing

# First step rename current dataset so it is not overwritten.####
# will need to change/remove renaming step once switched to seer

# 00 setup logger ----
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

# set up logger and system environment variable BYOC_MODE
if (exists("BYOC_MODE") && isTRUE(BYOC_MODE)) {
  logger::log_info("Detect run_sdl.r run on Denodo")
  Sys.setenv(BYOC_MODE = "TRUE")
} else {
  logger::log_info("Detect run_sdl.r run locally")
  BYOC_MODE <- FALSE
  Sys.setenv(BYOC_MODE = "FALSE")
}


# setup connection to Denodo if run locally
if (!BYOC_MODE) {
  # Open a connection to DVPREPROD (test environment) or DVPROD (production environment)
  denodo_connect <- suppressWarnings(dbConnect(
    odbc(),
    dsn = "DVPREPROD",
    # or DVPROD
    uid = .rs.askForPassword("Enter your username"),
    pwd = .rs.askForPassword("Enter your LDAP password")
  ))
}


write_to_disk <- TRUE

# just test one year
year <- "2019"
fyear <- convert_year_to_fyyear(year)

# dummy targets testing
targets::tar_make(script = "dummy_targets.R")

## disconnect from denodo if run locally ----
if (!BYOC_MODE) {
  logger::log_info("Disconnect from Denodo")
  DBI::dbDisconnect(denodo_connect)
}
