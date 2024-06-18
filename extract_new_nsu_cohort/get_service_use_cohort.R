################################################################################
# Name of file - get_service_use_cohort.R
# Original Authors - Jennifer Thom
# Original Date - August 2021
# Update - June 2024
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Use this script to return a list of CHIs from the most recent
#               SLF episode file (service users) in preparation for requesting
#               a new NSU cohort for the latest 'full year'
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
#
################################################################################

# Setup-------------------------------------------------------------------------

## Update ##
# The year of the new NSU extract we want
year <- "2324"

nsu_dir <- path("/conf/hscdiip/SLF_Extracts/NSU/")

# Read data---------------------------------------------------------------------
episode_file <- slfhelper::read_slf_episode(year, col_select = "anon_chi") %>%
  # Remove blank CHI
  dplyr::filter(!is.na(anon_chi)) %>%
  # Get CHI version for sending to the CHILI team.
  # For saving this on disk we want the anon-chi version, save this after sending
  # to the CHILI team.
  slfhelper::get_chi()

# Save a parquet file
episode_file %>%
  arrow::write_parquet(path(nsu_dir, glue::glue("service_user_extract_{year}.parquet")),
    compress = TRUE
  )

## End of Script ##
