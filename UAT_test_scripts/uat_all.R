## Setup environment ---
rm(list = ls())

# Load createslf package
devtools::load_all(".")

# Read in the package libraries
library(DBI)
library(odbc)
library(dplyr)
library(tibble)
library(purrr)
library("writexl")
library("openxlsx")
library("readxl")

# Open a connection to DVPREPROD (test environment)
# or DVPROD (production environment)
denodo_connect <- suppressWarnings(
  dbConnect(odbc(),
    dsn = "DVPREPROD", # or DVPROD
    uid = .rs.askForPassword("Username:"),
    pwd = .rs.askForPassword("Enter your test environment password")
  )
)

# Source functions
source(here::here("UAT_test_scripts/01_uat_functions.R"))

#-------------------------------------------------------------------------------

## Setup data --------------

# Analyst name for folder structure
analyst <- "Zihao"

name_list <- openxlsx::read.xlsx(
  file.path(
    get_dev_dir(),
    "uat_testing",
    "1_source_data_views",
    "Lookups",
    "uat_names.xlsx"
  )
)

datasets <- c("maternity", "ae")
name_list <- name_list %>%
  dplyr::filter(dataset_list %in% datasets)


for (ii in 1:nrow(name_list)) {
  dataset_name <- name_list$dataset_list[ii]
  fn_name <- name_list$fn_list[ii]
  sdl_name <- name_list$sdl_list[ii]

  source(here::here("UAT_test_scripts/02_uat_fn_script.R"))
}

DBI::dbDisconnect(denodo_connect)
