#####################################################
# GP Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Open Data, GP Practice Details, Postcode Lookup
# Description - Build the GPprac Lookup.
#               Pulls from the Open Data Platform and lookups.
#####################################################

# Load packages
library(dplyr)
library(tidyr)
library(phsopendata)
library(janitor)
library(fs)
library(createslf)

# Read in data---------------------------------------

# Retrieve the latest resource from the dataset
opendata <-
  get_dataset("gp-practice-contact-details-and-list-sizes",
    max_resources = 1
  ) %>%
  clean_names() %>%
  # Filter and save
  select(
    gpprac = practice_code,
    practice_name = gp_practice_name,
    gpprac_postcode = postcode,
    cluster = gp_cluster
  ) %>%
  # Sort for SPSS matching
  arrange(gpprac) %>%
  # Write out as an SPSS file
  write_sav(get_practice_details_path(check_mode = "write")) %>%
  # rds as well
  write_rds(get_practice_details_path(check_mode = "write"))


# Read Lookup files ---------------------------------------
# gp lookup
gpprac_file <-
  haven::read_sav(read_gpprac_file("gpprac.sav")) %>%
  # select only praccode and postcode
  select(
    gpprac = praccode,
    gpprac_postcode = postcode
  )

# postcode lookup
pc_lookup <- readr::read_rds(read_spd_file()) %>%
  select(
    pc7,
    pc8,
    hb2018,
    hscp2018,
    ca2018
  ) %>%
  # rename pc8
  rename(postcode = "pc8")


# Data Cleaning ---------------------------------------

gpprac_slf_lookup <-
  ## match cluster information onto the practice reference list ##
  left_join(opendata, gpprac_file, by = c("gpprac", "gpprac_postcode")) %>%
  # match on geography info - postcode
  left_join(pc_lookup, by = c("gpprac_postcode" = "postcode")) %>%
  # rename hb2018
  rename(hbpraccode = "hb2018") %>%
  # order variables
  select(
    gpprac,
    pc7,
    gpprac_postcode,
    cluster,
    hbpraccode,
    hscp2018,
    ca2018
  ) %>%
  # convert ca to lca code
  mutate(lca = convert_ca_to_lca(ca2018)) %>%
  # set some known dummy practice codes to consistent Board codes
  mutate(
    hbpraccode = if_else(gpprac %in% c(99942, 99957, 99961, 99981, 99999), "S08200003", hbpraccode),
    hbpraccode = if_else(gpprac == 99995, "S08200001", hbpraccode)
  ) %>%
  # sort by gpprac
  arrange(gpprac) %>%
  # rename pc8 back - saved in output as pc8
  rename(pc8 = "gpprac_postcode")


## save outfile ---------------------------------------

gpprac_slf_lookup %>%
  # .zsav
  write_sav(get_slf_gpprac_path(ext = "zsav", check_mode = "write")) %>%
  # .rds file
  write_rds(get_slf_gpprac_path(check_mode = "write"))


## End of Script ---------------------------------------
