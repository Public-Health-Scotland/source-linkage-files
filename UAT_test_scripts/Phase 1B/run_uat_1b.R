################################################################################ .
# Setup ----
################################################################################ .

library(dplyr)
library(stringr)
library(openxlsx)

source("UAT_test_scripts/Phase 1B/get_data.R")
source("UAT_test_scripts/Phase 1B/uat_1b_functions.R")

uat_folder <- "/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/1b_source_data_views_detailed/"
workbook_file <- paste0(uat_folder, "outputs/column_comparison.xlsx")

local_mapping <- read.csv(paste0(uat_folder, "lookups/local_column_mapping.csv"))
sdl_mapping <- read.csv(paste0(uat_folder, "lookups/sdl_column_mapping.csv"))
sdl_filters <- read.csv(paste0(uat_folder, "lookups/sdl_filters.csv"))

################################################################################ .
# Run comparison ----
################################################################################ .

year <- "1920"

for (test_dataset in get_types(c("boxi", "sc"))) {
  summary_df <- compare_data(test_dataset, year, local_mapping, sdl_mapping, sdl_filters)
  save_as_sheet(summary_df, workbook_file)
}
