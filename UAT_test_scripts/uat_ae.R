################################################################################
# Name of file - UAT_ae.R
#
# Original Authors - Jennifer Thom
# Original Date - January 2026
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description: UAT testing script to check the source data views.
#              This relates to data coming directly from the CDW
#              which were previously extracted using BOXI.
#
################################################################################

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

dataset_name <- "ae"

# Read in Test data
sdl_view <- as_tibble(dbGetQuery(
  denodo_connect,
  "select * from sdl.sdl_ae2_episode_level_source LIMIT 100"
))

# Read boxi data
boxi_view <- read_extract_ae(year = "1920")

# Read denodo variables for renaming SLF variables
denodo_vars <- readxl::read_excel("/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/SLF_variable_lookup.xlsx",
  sheet = "ae"
)


#-------------------------------------------------------------------------------

## Create Output --------
ae_output <- create_uat_output(
  dataset_name = dataset_name,
  boxi_data = boxi_view,
  sdl_data = sdl_view,
  denodo_vars = denodo_vars
)

## Write to Excel workbook
homelessness_output %>%
  write_uat_tests(sheet_name = "ae")

# End of Script #

boxi_data <- boxi_view
sdl_data <- sdl_view
