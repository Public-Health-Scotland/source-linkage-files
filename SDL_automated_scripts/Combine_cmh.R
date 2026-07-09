# Combine Community Mental Health files
#
# Original Author - Zihao Li
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment ------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
cmh_dir <- "/conf/hscdiip/SLF_Extracts/Archived_data"
pattern <- "anon-Community-MH-contact-level-extract-20(\\d{4})\\.csv.gz"

# List all the CSV files in the source directory
cat(stringr::str_glue("Looking in '{cmh_dir}' for csv files."))
csv_files <- list.files(cmh_dir, pattern = pattern, full.names = TRUE)
print(stringr::str_glue("Found {length(csv_files)} csv files to process."))


## Stage 2 - Read and clean columns before binding ---------------
cmh_files <- purrr::map(csv_files, function(cmh_files) {
  year <- stringr::str_extract(basename(cmh_files), "(\\d{6})")
  year <- stringr::str_sub(year, 3, 6)
  df <- read_file(
    cmh_files,
    col_types = readr::cols_only(
      "anon_chi" = readr::col_character(),
      "Patient DoB Date [C]" = readr::col_date(format = "%Y/%m/%d %T"),
      "Gender" = readr::col_double(),
      "Patient Postcode [C]" = readr::col_character(),
      "NHS Board of Residence Code 9" = readr::col_character(),
      "Patient HSCP Code - current" = readr::col_character(),
      "Practice Code" = readr::col_integer(),
      "Treatment NHS Board Code 9" = readr::col_character(),
      "Contact Date" = readr::col_date(format = "%Y/%m/%d %T"),
      "Contact Start Time" = readr::col_time(format = "%T"),
      "Duration of Contact" = readr::col_integer(),
      "Location of Contact" = readr::col_character(),
      "Main Aim of Contact" = readr::col_character(),
      "Other Aim of Contact (1)" = readr::col_character(),
      "Other Aim of Contact (2)" = readr::col_character(),
      "Other Aim of Contact (3)" = readr::col_character(),
      "Other Aim of Contact (4)" = readr::col_character()
    )
  ) %>%
    dplyr::mutate(year = year)
  return(df)
})

## Stage 3 - Bind files together and save to disk ----------
cmh_combined_output <- dplyr::bind_rows(cmh_files)

cmh_combined_output %>%
  write_file(get_combined_cmh_path(check_mode = "write"))
