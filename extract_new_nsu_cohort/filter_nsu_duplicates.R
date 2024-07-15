################################################################################
# Name of file - filter_nsu_duplicates.R
# Original Authors - James McMahon, Jennifer Thom
# Original Date - August 2021
# Update - June 2024
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Use this script to filter NSU duplicates when taking a new
#               extract from the CHILI team.
#
# Steps for requesting a new NSU extract for SLFs:
#       1. Send an email to [phs.chi-recordlinkage@phs.scot] to request a new NSU
#          extract after the JUNE update.
#       2. Prepare a service use extract. Run script `get_service_use_cohort.R` to
#          extract a list of CHI's from the most recent 'full' file.
#       3. Once the chili team come back to us, send the service use extract to
#          the analyst directly. Do not send the list of CHIs to the mailbox for
#          Information Governance purposes.
#       4. CHILI team will then process the new NSU extract based on who is not in
#          the service use extract.
#       5. Run the script `filter_nsu_duplicates.R` to collect the new NSU
#          extract from the analysts SMRA space - see lines 46-47 and change
#          username accordingly. Save the extract in:
#          "/conf/hscdiip/SLF_Extracts/NSU"
################################################################################

library(dplyr)
library(purrr)
library(stringr)
library(PostcodesioR)
library(janitor)
library(fs)
library(glue)


## Setup------------------------------------------------------------------------

## Update line 41##
# The year of new NSU extract
year <- "2324"

# Update lines 45-46 ##
# Analysts username and schema to collect the data.
analyst <- "ROBERM18"
schema <- "FINAL_2"

#  setup directory
nsu_dir <- path("/conf/hscdiip/SLF_Extracts/NSU")

# latest geography file
spd_path <- get_file_path(
  directory = fs::path(
    fs::path("/", "conf", "linkage", "output", "lookups", "Unicode"),
    "Geography",
    "Scottish Postcode Directory"
  ),
  file_name = NULL,
  file_name_regexp = stringr::str_glue("Scottish_Postcode_Directory_.+?\\.parquet")
)

# Set up connection to SMRA-----------------------------------------------------
db_connection <- odbc::dbConnect(
  odbc::odbc(),
  dsn = "SMRA",
  uid = Sys.getenv("USER"),
  pwd = rstudioapi::askForPassword("password")
)


# Read data---------------------------------------------------------------------

# Read NSU data with duplicates from analyst's SMRA space.
nsu_data <-
  tbl(db_connection, dbplyr::in_schema(analyst, schema)) %>%
  collect() %>%
  clean_names()


# Data cleaning-----------------------------------------------------------------

# Find the records with duplicates
nsu_pc_duplicates <- nsu_data %>%
  group_by(upi_number) %>%
  mutate(postcode_count = n_distinct(postcode)) %>%
  ungroup() %>%
  filter(postcode_count > 1)

# Get the latest SPD
spd <- read_file(spd_path) %>%
  select(pc7, date_of_introduction, date_of_deletion)

# Load some regex to check if a postcode is valid
pc_regex <-
  "([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\\s?[0-9][A-Za-z]{2})"

# Main code to check postcodes in various ways
nsu_pc_duplicates_checked <- nsu_pc_duplicates %>%
  select(
    upi_number,
    start_date,
    postcode,
    date_address_changed,
    gp_prac_no,
    date_gp_acceptance
  ) %>%
  # First check against the regex
  mutate(invalid_pc = str_detect(postcode, pc_regex, negate = TRUE)) %>%
  # Now check against the SPD
  left_join(spd, by = c("postcode" = "pc7")) %>%
  # Now check against postcodes.io
  left_join(
    # Filter to only postcodes that need checking
    group_by(., upi_number) %>%
      # UPI has no postcode which matched the SPD
      filter(
        all(is.na(
          date_of_introduction
        ))
      ) %>%
      ungroup() %>%
      # No need to check invalid postcodes
      filter(!invalid_pc) %>%
      # Pass the unique list of postcodes to
      # postcodes.io
      pull(postcode) %>%
      unique() %>%
      list(postcodes = .) %>%
      # This function will fail if more than 100 pcs
      PostcodesioR::bulk_postcode_lookup() %>%
      # Parse the result, we only want the country
      map_dfr(~ tibble(
        postcode = .x$query,
        # Create an order to make sorting nice later
        country = ordered(.x$result$country, c("Scotland", "Wales", "England"))
      ))
  ) %>%
  # Sort so that the 'best' postcode is top of the list
  mutate(priority = case_when(
    # If they matched SPD,
    !is.na(date_of_introduction) & is.na(date_of_deletion) ~ 0,
    # If the matched SPD (and had a d_o_d)
    !is.na(date_of_introduction) ~ 1,
    # If they matched the postcodes.io API request
    !is.na(country) ~ 2,
    # Invalid postcodes come last
    invalid_pc ~ Inf,
    TRUE ~ 99
  )) %>%
  arrange(
    upi_number,
    priority,
    # newest introduced come first
    desc(date_of_introduction),
    # latest deleted will be first
    desc(date_of_deletion),
    # Scotland will be preferred etc.
    country
  ) %>%
  # Flag each row with the assigned priority
  group_by(upi_number) %>%
  mutate(keep_priority = row_number()) %>%
  ungroup()

# Check
nsu_pc_duplicates_checked %>%
  count(priority, keep_priority)

final_data <- nsu_data %>%
  # Filter the main dataset to remove
  # the duplicate postcodes we decided not to keep
  anti_join(nsu_pc_duplicates_checked %>%
    filter(keep_priority > 1)) %>%
  # Filter any remaining duplicates (none on this test)
  distinct(upi_number, .keep_all = TRUE) %>%
  select(
    chi = upi_number,
    dob = date_of_birth,
    postcode,
    gpprac = gp_prac_no,
    gender = sex
  ) %>%
  mutate(
    year = year, .before = everything(),
    dob = as.Date(dob),
    across(c(gender, gpprac), as.integer)
  ) %>%
  arrange(chi) %>%
  # Save as anon chi on disk
  slfhelper::get_anon_chi()

# Save data out to be used
final_data %>%
  arrow::write_parquet(path(nsu_dir, glue::glue("anon-All_CHIs_20{year}.parquet")),
    compression = "zstd"
  )


## End of Script ##
