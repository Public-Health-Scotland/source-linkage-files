# Combine District Nursing files
#
# Original Author - Zihao Li
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment ------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
dn_dir <- "/conf/hscdiip/SLF_Extracts/Archived_data"
pattern <- "anon-District-Nursing-contact-level-extract-20(\\d{4})\\.csv.gz"

# List all the CSV files in the source directory
cat(stringr::str_glue("Looking in '{dn_dir}' for parquet files."))
csv_files <- list.files(dn_dir, pattern = pattern, full.names = TRUE)
print(stringr::str_glue("Found {length(csv_files)} csv files to process."))


## Stage 2 - Read and clean columns before binding ---------------
dn_files <- purrr::map(csv_files, function(dn_files) {
  year <- stringr::str_extract(basename(dn_files), "(\\d{6})")
  year <- stringr::str_sub(year, 3, 6)
  df <- read_file(
    dn_files,
    col_types = readr::cols_only(
      `Treatment NHS Board Code 9` = readr::col_character(),
      `Age at Contact Date` = readr::col_integer(),
      `Contact Date` = readr::col_date(format = "%Y/%m/%d %T"),
      `Primary Intervention Category` = readr::col_character(),
      `Other Intervention Category (1)` = readr::col_character(),
      `Other Intervention Category (2)` = readr::col_character(),
      `anon_chi` = readr::col_character(),
      `Patient DoB Date [C]` = readr::col_date(format = "%Y/%m/%d %T"),
      `Patient Postcode [C] (Contact)` = readr::col_character(),
      `Duration of Contact (measure)` = readr::col_double(),
      Gender = readr::col_double(),
      `Location of Contact` = readr::col_character(),
      `Practice NHS Board Code 9 (Contact)` = readr::col_character(),
      `Patient Council Area Code (Contact)` = readr::col_character(),
      `Practice Code (Contact)` = readr::col_character(),
      `NHS Board of Residence Code 9 (Contact)` = readr::col_character(),
      `HSCP of Residence Code (Contact)` = readr::col_character(),
      `Patient Data Zone 2011 (Contact)` = readr::col_character()
    )
  ) %>%
    dplyr::mutate(year = year)
  current_names <- names(df)
  return(df)
})

## Stage 3 - Bind files together and save to disk -----------
dn_combined_output <- dplyr::bind_rows(dn_files)

dn_combined_output %>%
  write_file(get_combined_dn_path(check_mode = "write"))
