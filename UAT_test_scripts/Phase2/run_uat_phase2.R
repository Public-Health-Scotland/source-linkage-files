################################################################################
# Name of file - run_uat_phase2.R
#
# Original Authors - Jennifer Thom
# Original Date - August 2026
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description: UAT test scrips - phase2.
#
#################################################################################

# Setup environment ---
rm(list = ls())

# Load createslf package
devtools::load_all(".")

# Turn off scientific notation
options(scipen = 999)

# Read in the package libraries
library(DBI)
library(odbc)
library(dplyr)
library(tibble)
library(tidyr)
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
source(here::here("UAT_test_scripts/Phase1/01_uat_functions.R"))
source(here::here("UAT_test_scripts/Phase2/00_phase2_functions.R"))

#-------------------------------------------------------------------------------
# Set up environment ---

# Test year
year <- "1920"

# Dataset to test
datasets <- c("maternity")

# Analyst name for writing to disk
analyst <- "Jen"

# Read name list for matching each dataset function/sdl name
name_list <- readxl::read_excel(get_name_list_lookup()) %>%
  dplyr::filter(dataset_list %in% datasets) %>%
  dplyr::arrange(dataset_list)


#-------------------------------------------------------------------------------
# Create a loop for running multiple datasets ---
for (ii in 1:nrow(name_list)) {
  dataset_name <- name_list$dataset_list[ii]
  year <- year
  sdl_name_processed <- name_list$sdl_processed[ii]

  log_info(
    "UAT run {ii}/{nrow(name_list)} | dataset = {dataset_name}, sdl_name_processed = {sdl_name_processed}"
  )

  source(here::here("UAT_test_scripts/Phase2/01_phase2_setup.R"))
}

# END OF SCRIPT #
