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
# sdl_wip_data <- as_tibble(dbGetQuery(
#   denodo_connect,
#   glue::glue("select * from sdl.{sdl_name_processed}")
# ))

# Workaround: Read in data that has been read from SDL cached, processed manually and output saved.
sdl_wip_data <- arrow::read_parquet("/conf/sourcedev/Source_Linkage_File_Updates/uat_testing/3_dataset_processing/anon-maternity_for_source-201920.parquet")


#############################
## SLF Current data
#############################

# For latest data in sourcedev use:
# slf_current_data <- read_file(get_source_extract_path(year = year, type = dataset_name))

# Read in June update data
slf_current_data <- read_file(get_slf_current_data_path(year = year, type = dataset_name))

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
