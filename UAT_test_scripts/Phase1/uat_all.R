################################################################################
# Name of file - uat_all.R
#
# Original Authors - Jennifer Thom
# Original Date - January 2026
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description: Functions used to support the UAT test scrips.
#
#################################################################################

# Setup environment ---
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
library(logger)

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
analyst <- "Jen"

datasets <- c("acute", "nrs_deaths", "gp_ooh_consultations")

# Read name list for matching each dataset function/sdl name
name_list <- readxl::read_excel(get_name_list_lookup()) %>%
  dplyr::filter(dataset_list %in% datasets) %>%
  dplyr::arrange(dataset_list)


for (ii in 1:nrow(name_list)) {
  dataset_name <- name_list$dataset_list[ii]
  fn_name <- name_list$fn_list[ii]
  sdl_name <- name_list$sdl_list[ii]

  log_info(
    "UAT run {ii}/{nrow(name_list)} | dataset = {dataset_name}, function = {fn_name}, sdl_name = {sdl_name}"
  )

  source(here::here("UAT_test_scripts/02_uat_fn_script.R"))
}


################################################################################
## DEBUGGING

# If you need to run one dataset within this loop, assign ii to the row number
# and run the following code. This will put everything you need into the
# environment then you can run through 02_uat_fn_script and 01_uat_functions
# to see where the problem is

# Assign row number (returns the dataset you want to look at in names_list)
# ii <- 3

# After Assigning ii as the row number you want to investigate, run the
# following code:
# dataset_name <- name_list$dataset_list[ii]
# fn_name <- name_list$fn_list[ii]
# sdl_name <- name_list$sdl_list[ii]

# Now run lines 1-13 in 02_uat_fn_script.r and line by line in
# 01_uat_functions.r to debug

#################################################################################

DBI::dbDisconnect(denodo_connect)
