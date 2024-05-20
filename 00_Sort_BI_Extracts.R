# Define the source directory and financial year pattern
compress_files <- TRUE
source_dir <- "/conf/sourcedev/Source_Linkage_File_Updates/Extracts Temp"
pattern <- "-20(\\d{4})\\.csv"


# List all the CSV files in the source directory
cat(stringr::str_glue("Looking in '{source_dir}' for csv files."))
csv_files <- list.files(source_dir, pattern = ".csv", full.names = TRUE)
print(stringr::str_glue("Found {length(csv_files)} csv files to process."))

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

# Create a function to read variable names
is_chi_in_file <- function(filename) {
  data <- read.csv(filename, nrow = 1)
  return(grepl("UPI", names(data)) %>% any())
}

# function to move files
move_temps_to_year_extract <- function(csv_file, compress_files = TRUE) {
  financial_year <- extract_financial_year(csv_file)
  # check if year directory exists
  if (!is.null(financial_year)) {
    financial_year_dir <- file.path("/conf/sourcedev/Source_Linkage_File_Updates", financial_year, "Extracts")
    # if financial_year_dir does not exist, create the year directory
    if (!dir.exists(financial_year_dir)) {
      dir.create(financial_year_dir)
    }

    # set up new file path location to move each file to their destination.
    chi_in_file <- is_chi_in_file(csv_file)
    if (chi_in_file) {
      new_file_path <- file.path(
        financial_year_dir,
        paste0("anon-", basename(csv_file))
      )
      read_file(csv_file) %>%
        dplyr::rename_with(~ paste0("chi"), tidyselect::contains("UPI")) %>%
        slfhelper::get_anon_chi() %>%
        readr::write_csv(file = new_file_path)
      cat("Replaced chi with anon chi:", csv_file, "to", new_file_path, "\n")
    } else {
      new_file_path <- file.path(financial_year_dir, basename(csv_file))
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

lapply(csv_files, move_temps_to_year_extract, compress_files = compress_files)
