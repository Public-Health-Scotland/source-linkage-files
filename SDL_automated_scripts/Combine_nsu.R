##########################
# Combine NSU files
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
nsu_dir <- "/conf/hscdiip/SLF_Extracts/NSU"
pattern <- "anon-All_CHIs_20(\\d{4})\\.parquet"

# List all the CSV files in the source directory
cat(stringr::str_glue("Looking in '{nsu_dir}' for parquet files."))
parquet_files <- list.files(nsu_dir, pattern = pattern, full.names = TRUE)
print(stringr::str_glue("Found {length(parquet_files)} parquet files to process."))


## Stage 2 - Read and clean columns before binding
#-------------------------------------------------------------------------------
nsu_files <- purrr::map(
  parquet_files,
  function(nsu_files) {
    df <- read_file(nsu_files) %>%
      dplyr::mutate(gpprac = as.character(gpprac))
    current_names <- names(df)
    return(df)
  }
)

## Stage 3 - Bind files together and save to disk
#-------------------------------------------------------------------------------
nsu_combined_output <- dplyr::bind_rows(nsu_files)

nsu_combined_output %>%
  write_file(get_combined_nsu_path())


## END OF SCRIPT ##
