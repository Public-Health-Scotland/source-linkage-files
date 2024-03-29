library(dplyr)
library(fs)
library(haven)
library(glue)

nsu_dir <- path("/conf/hscdiip/SLF_Extracts/NSU")

# Change the year
fin_year <- "2223"

db_connection <- odbc::dbConnect(
  odbc::odbc(),
  dsn = "SMRA",
  uid = Sys.getenv("USER"),
  pwd = rstudioapi::askForPassword("password")
)

# Check the table name and change if required.
table <- dbplyr::in_schema("ROBERM18", "FINAL_1")

# Read NSU data
nsu_data <-
  tbl(db_connection, table) %>%
  mutate(
    year = fin_year,
    gender = as.integer(SEX)
  ) %>%
  select(year,
    chi = UPI_NUMBER,
    dob = DATE_OF_BIRTH,
    postcode = POSTCODE,
    gpprac = GP_PRAC_NO,
    gender
  ) %>%
  collect()

# Write out the data
file_path <- path(nsu_dir, glue("All_CHIs_20{fin_year}.parquet"))
# This will archive the existing file for later comparison
if (file_exists(file_path)) {
  file_copy(file_path, path(nsu_dir, glue("All_CHIs_20{fin_year}_OLD.parquet")))
}

nsu_data %>%
  arrow::write_parquet(file_path, compression = "zstd", compression_level = 10)
