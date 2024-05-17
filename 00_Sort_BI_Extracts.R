# Define the source directory and financial year pattern
compress_files <- FALSE
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

# Create directories for each financial year and move files
for (csv_file in csv_files) {
  financial_year <- extract_financial_year(csv_file)
  # check if year directory exists
  if (!is.null(financial_year)) {
    financial_year_dir <- file.path("/conf/sourcedev/Source_Linkage_File_Updates", financial_year, "Extracts")
    # if not, create the year directory
    if (!dir.exists(financial_year_dir)) {
      dir.create(financial_year_dir)
    }

    # compress file
    if (compress_files) {
      cat("Compressing:", basename(csv_file), "\n")
      system2(
        command = "gzip",
        args = shQuote(csv_file)
      )
      csv_file <- paste0(csv_file, ".gz")
    }

    # move file
    new_file_path <- file.path(financial_year_dir, paste0("anon-",basename(csv_file)))

    # Read in each file and replace chi with anon_chi
    for (csv_file in csv_files) {
      hl1<- read_file(csv_file) %>%
        dplyr::rename(chi = 'UPI Number [C]') %>%
        slfhelper::get_anon_chi() %>%
        readr::write_csv(file = new_file_path)
    }

    #fs::file_copy(csv_file, new_file_path, overwrite = TRUE)
    file.remove(csv_file)
    cat("Replaced chi with anon chi:", csv_file, "to", new_file_path, "\n")
  }
}
