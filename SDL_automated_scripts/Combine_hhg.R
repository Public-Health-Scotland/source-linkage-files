##########################
# Combine HHG files
#
# Original Author - Jennifer Thom
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.2.2
##########################


## Stage 1 - Setup environment
#-------------------------------------------------------------------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
hhg_dir <- "/conf/hscdiip/SLF_Extracts/HHG"
pattern <- "anon-HHG-20(\\d{4})\\.parquet"

# List all the CSV files in the source directory
cat(stringr::str_glue("Looking in '{hhg_dir}' for parquet files."))
parquet_files <- list.files(hhg_dir, pattern = pattern, full.names = TRUE)
print(stringr::str_glue("Found {length(parquet_files)} parquet files to process."))


## Stage 2 - Read and clean columns before binding
#-------------------------------------------------------------------------------
hhg_files <- purrr::map(
  parquet_files,
  function(hhg_files) {
    year <- stringr::str_extract(basename(hhg_files), "(\\d{6})")
    year <- stringr::str_sub(year, 3, 6)
    df <- read_file(hhg_files) %>%
      dplyr::mutate(year = year)
    current_names <- names(df)
    return(df)
  }
)

## Stage 3 - Bind files together and save to disk
#-------------------------------------------------------------------------------
hhg_combined_output <- dplyr::bind_rows(hhg_files)

hhg_combined_output %>%
  write_file(get_combined_hhg_path(check_mode = "write"))
