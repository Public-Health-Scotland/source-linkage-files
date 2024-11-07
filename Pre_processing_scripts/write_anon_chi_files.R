################################################################################
# Name of file -  Write_anon_chi_files.R
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - July 2024
# Written/run on - R Posit
# Version of R - 4.1.2
#
# Description: Run this script in stages to convert chi to anon chi and save files.
#              By default this is set up to take the delayed discharges file
#              convert the chi to anon_chi and save to disk. Important for
#              ensuring we do not save chi anywhere on disk.
#
################################################################################

## Stage 1 - Setup environment
#-------------------------------------------------------------------------------

# Set up directory
source_dir <- "/conf/hscdiip/SLF_Extracts/Delayed_Discharges"

# Specify type of files e.g parquet, rds, csv
pattern <- ".parquet"
cat(stringr::str_glue("Looking in '{source_dir}' for parquet files."))

# List all files in the directory
parquet_files <- list.files(source_dir, pattern = ".parquet", full.names = TRUE)
print(stringr::str_glue("Found {length(parquet_files)} parquet files to process."))

# Create a function to read variable names and check if CHI is in the file
is_chi_in_file <- function(filename) {
  data <- arrow::read_parquet(filename, nrow = 5)
  return(grepl("chi", names(data)) %>% any())
}


# Stage 2 - In each file, convert chi to anon_chi and save to disk
#-------------------------------------------------------------------------------

  # create a loop for converting to anon chi in all listed files
  for (data_file in parquet_files) {
    # specify new name and new file path
    save_file_path <- file.path(source_dir, paste0("anon-", basename(data_file)))
    chi_in_file <- is_chi_in_file(data_file)

    # If chi is in the file, convert to anon_chi
    if (chi_in_file) {
      read_file(data_file) %>%
        slfhelper::get_anon_chi() %>%
        write_file(save_file_path)

      cat("Replaced chi with anon chi:", data_file, "to", save_file_path, "\n")
    } else {
      read_file(data_file) %>%
        write_file(save_file_path)
      cat("renamed file with anon chi:", data_file, "to", save_file_path, "\n")
    }
  }


# Stage 3 - Remove files with CHI
#-------------------------------------------------------------------------------

  # Create a loop for removing the old files with CHI
  for (data_file in parquet_files) {
    file.remove(data_file)
    cat("Removed chi files:", data_file, "in", source_dir, "\n")
  }

# End of Script #
