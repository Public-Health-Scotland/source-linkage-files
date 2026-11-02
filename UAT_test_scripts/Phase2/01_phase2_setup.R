################################################################################
# Name of file - 01_phase2_setup.R
#
# Original Authors - Jennifer Thom
# Original Date - August 2026
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description: UAT test scrips - phase2.
#
#################################################################################

## Set up data ---

##############################################
# TODO: Processed data is not available in SDL
##############################################

#############################
## SDL WIP data
#############################

# Read in SDL Test data
sdl_wip_data <- as_tibble(dbGetQuery(
  denodo_connect,
  glue::glue("select * from sdl.{sdl_name_processed}")
))

# Workaround: Read in data that has been read from SDL cached, processed manually and output saved.
# sdl_wip_data <- arrow::read_parquet("/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/3_dataset_processing/anon-maternity_for_source-201920.parquet")


#############################
## SLF Current data
#############################

recode_datasets <- function(x) {
  dplyr::recode(
    x,
    "acute" = "acute",
    "ae" = "ae",
    "delayed_discharges" = "dd",
    "dn" = "dn",
    "gp_ooh_all" = "gp_ooh",
    "homelessness" = "homelessness",
    "mental_health" = "mh",
    "nrs_deaths" = "nrs_deaths",
    "outpatients" = "outpatients",
    "maternity" = "maternity",
    "combined_deaths" = "combined_deaths",
    "chi_deaths" = "chi_deaths",
    "dn_cost_lookup" = "dn_cost_lookup",
    .default = x
  )
}

dataset_name2 <- recode_datasets(dataset_name)

# For latest data in sourcedev use:
# slf_current_data <- read_file(get_source_extract_path(year = year, type = dataset_name2, BYOC_MODE = FALSE))

# Read boxi data
if (isTRUE(year_specific) && isFALSE(type_specific)) {
  slf_current_data <- get(fn_name_processed)(year = "1920", BYOC_MODE = FALSE)
} else {
  slf_current_data <- get(fn_name_processed)(BYOC_MODE = FALSE)
}

slf_current_data <- read_file(slf_current_data)

# } else if (isFALSE(year_specific) && isTRUE(type_specific)) {
#   boxi_data <- get(fn_name)(type = type_name)
# } else if (isTRUE(year_specific) && isTRUE(type_specific)) {
#   boxi_data <- get(fn_name)(year = "1920", type = type_name)
# } else {
#   boxi_data <- get(fn_name)()
# }
#
# if (is(boxi_data, "fs_path")) {
#   ext <- fs::path_ext(boxi_data)
#
#   if (ext == "xlsx") {
#     boxi_data <- readxl::read_excel(boxi_data)
#   } else {
#     boxi_data <- read_file(boxi_data) # %>% janitor::clean_names()
#   }
# }


#-------------------------------------------------------------------------------
# Output statistics -----

#############################
## Create Output
#############################

# Call main function create_phase2_output
dataset_output <- create_phase2_output(
  dataset_name = dataset_name,
  year = year,
  slf_current_data = slf_current_data,
  sdl_wip_data = sdl_wip_data
)


#############################
## Write to Excel workbook
#############################
# Call main function write_phase2_tests
dataset_output %>%
  write_phase2_tests(
    sheet_name = dataset_name,
    analyst = analyst
  )

# End of Script #
