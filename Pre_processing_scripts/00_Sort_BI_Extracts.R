################################################################################
# Name of file -  00_Sort_BI_Extracts.R
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - July 2024
# Written/run on - R Posit
# Version of R - 4.1.2
#
# Description:
#     Run this script in stages to check and sort BI extracts into each year
#     specific folder with anon_chi attached. The script will look for extracts
#     in:
#             /conf/sourcedev/Source_Linkage_File_Updates/Extracts Temp
#     This will then extract the financial year from each extract and set up to
#     move files to each respective year/extracts folder e.g:
#             /conf/sourcedev/Source_Linkage_File_Updates/1920/Extracts
#     Once the extract has moved this will now have the anon_chi and the file
#     will be renamed e.g: "anon-Acute-episode-level-extract-201920.csv.gz" This
#     will also use compression to save space in sourcedev.
#
################################################################################

## Stage 1 - Setup environment
#-------------------------------------------------------------------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
compress_files <- FALSE
source_dir <- "/conf/sourcedev/Source_Linkage_File_Updates/Extracts Temp"
pattern <- "-20(\\d{4})\\.csv"


# List all the CSV files in the source directory
cat(stringr::str_glue("Looking in '{source_dir}' for csv files."))
csv_files <- list.files(source_dir, pattern = ".csv", full.names = TRUE)
print(stringr::str_glue("Found {length(csv_files)} csv files to process."))


## Stage 2 - Setup functions
#-------------------------------------------------------------------------------

# Function 1--
# Create a function to extract the financial year from a filename
extract_financial_year <- function(filename) {
  match <- regexpr(pattern, basename(filename))
  if (match[[1]][1] > 0) {
    financial_year <- substr(basename(filename), match[[1]][1] + 3, match[[1]][1] + 6)
    return(financial_year)
  } else {
    return(NULL)
  }
}

# Function 2--
# Create a function to move files to the correct location
move_temps_to_year_extract <- function(csv_file, compress_files = TRUE) {
  financial_year <- extract_financial_year(csv_file)
  # check if year directory exists
  if (!is.null(financial_year)) {
    financial_year_dir <- file.path("/conf/sourcedev/Source_Linkage_File_Updates", financial_year, "Extracts")
    # if financial_year_dir does not exist, create the year directory
    if (!dir.exists(financial_year_dir)) {
      dir.create(financial_year_dir)
    }

    # Set up the new file path with the "anon-" prefix
    new_file_path <- file.path(financial_year_dir, paste0("anon-", basename(csv_file)))

    # set up new file path location to move each file to their destination.
    chi_in_file <- is_chi_in_file(csv_file)
    if (chi_in_file) {
      read_file(csv_file) %>%
        dplyr::rename_with(~ paste0("chi"), tidyselect::contains("UPI", ignore.case = FALSE)) %>%
        slfhelper::get_anon_chi() %>%
        readr::write_csv(file = new_file_path)
      cat("Replaced chi with anon chi:", csv_file, "to", new_file_path, "\n")
    } else {
      fs::file_copy(csv_file, new_file_path, overwrite = TRUE)
      cat("Moved", csv_file, "to", new_file_path, "\n")
    }

    # compress file
    if (compress_files) {
      cat("Compressing:", basename(new_file_path), "\n")
      system2(
        command = "gzip",
        args = shQuote(new_file_path)
      )
    }
    # remove old files
    file.remove(csv_file)
  }
}

## Stage 3 - Use lapply to move the list of files to the correct folders.
#            lapply works by applying the functions to each file.
#-------------------------------------------------------------------------------
lapply(csv_files, move_temps_to_year_extract, compress_files = compress_files)

#-------------------------------------------------------------------------------

## End of Script ##
