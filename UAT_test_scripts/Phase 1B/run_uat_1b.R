################################################################################ .
# Setup ----
################################################################################ .

library(dplyr)
library(stringr)
library(openxlsx)
library(readr)

source("UAT_test_scripts/Phase 1B/get_data.R")
source("UAT_test_scripts/Phase 1B/uat_1b_functions.R")

uat_folder <- "/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/1b_source_data_views_detailed/"
workbook_file <- paste0(uat_folder, "outputs/column_comparison.xlsx")

local_mapping <- read.csv(paste0(uat_folder, "lookups/local_column_mapping.csv"))
sdl_mapping <- read.csv(paste0(uat_folder, "lookups/sdl_column_mapping.csv"))
sdl_filters <- read.csv(paste0(uat_folder, "lookups/sdl_filters.csv"))

year <- "1920"

################################################################################ .
# Run comparison ----
################################################################################ .

for (test_dataset in c(
  get_types("boxi"),
  get_types("sc"),
  get_types("lookup"),
  get_types("opendata"),
  get_types("archive"),
  "dd",
  "nsu"
)) {
  print(test_dataset)
  summary_df <- compare_data(test_dataset, year, local_mapping, sdl_mapping, sdl_filters)
  save_as_sheet(summary_df, workbook_file)
}

# On hold
# "chi_deaths", "ltc", "pis", "sparra"

################################################################################ .
# Split by failure type ----
################################################################################ .

all_data <- excel_sheets(file) %>%
  lapply(\(sheet) read_excel(file, sheet = sheet)) %>%
  bind_rows()

local_only <- all_data %>%
  filter(in_sdl == FALSE) %>%
  select(type, colname, local_original_colname)

sdl_only <- all_data %>%
  filter(in_local == FALSE) %>%
  select(type, colname, sdl_original_colname)

type_mismatch <- all_data %>%
  filter(type_match == FALSE) %>%
  select(type, colname, sdl_original_colname, local_original_colname, sdl_type, local_type)

row_mismatch <- all_data %>%
  filter(change_total_vals != 0) %>%
  select(type, total_vals_local, total_vals_sdl, change_total_vals, perc_change_total_vals) %>%
  distinct()

data_mismatch <- all_data %>%
  filter(
    in_both == TRUE,
    type_match == TRUE,
    change_total_vals == 0,
    (unique_vals_mismatch != 0 | unique_vals_with_different_counts != 0)
  ) %>%
  select(
    type, colname, sdl_original_colname, local_original_colname,
    local_na_count, sdl_na_count, change_na, perc_change_na, unique_vals_local,
    unique_vals_sdl, change_unique_vals, perc_change_unique_vals,
    unique_vals_mismatch, unique_vals_with_different_counts
  )

data_frames <- list(
  local_only = local_only,
  sdl_only = sdl_only,
  type_mismatch = type_mismatch,
  row_mismatch = row_mismatch,
  data_mismatch = data_mismatch
)

write.xlsx(
  data_frames,
  file = paste0(uat_folder, "outputs/column_comparison_split.xlsx"),
  overwrite = TRUE
)
