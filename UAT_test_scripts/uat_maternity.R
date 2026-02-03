################################################################################
# Name of file - UAT_maternity.R
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
rm()

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
analyst <- "Jen"

# Dataset name for ID
dataset_name <- "maternity"

# Read in Test data
sdl_view <- as_tibble(dbGetQuery(
  denodo_connect,
  "select * from sdl.sdl_maternity_episode_source LIMIT 100"
))

# Read boxi data
boxi_view <- read_extract_maternity(year = "1920")

# Read denodo variables for renaming SLF variables
denodo_vars <- readxl::read_excel(get_slf_variable_lookup(),
                                  sheet = dataset_name)

#-------------------------------------------------------------------------------

## Create Output --------
maternity_output <- create_uat_output(
  dataset_name = dataset_name,
  boxi_data = boxi_view,
  sdl_data = sdl_view,
  denodo_vars = denodo_vars
)

## Write to Excel workbook
maternity_output %>%
  write_uat_tests(sheet_name = dataset_name,
                  analyst = analyst)

# End of Script #
