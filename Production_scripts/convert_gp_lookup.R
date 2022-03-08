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


## packages ##
library(dplyr)
library(tidyr)
library(haven)
library(phsopendata)
library(janitor)
library(fs)


## get data ##

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
    postcode,
    cluster = gp_cluster
  ) %>%
  # Sort for SPSS matching
  arrange(gpprac) %>%
  # Write as an SPSS file
  write_sav(
    path(
      # lookup_dir,
      get_practice_details_path()
    ),
    compress = TRUE
  )


# Read Lookup files ---------------------------------------
# gp lookup
gpprac_file <-
  haven::read_sav(read_gpprac_file("gpprac.sav")) %>%
  # select only praccode and postcode
  select(
    praccode,
    postcode
  ) %>%
  # sort by praccode
  arrange(praccode) %>%
  # rename praccode to allow join
  rename(gpprac = "praccode")


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


## Data Cleaning ##
data <-
  opendata %>%
  ## match cluster information onto the practice reference list ##
  left_join(gpprac_file, by = c("gpprac", "postcode")) %>%
  # sort by postcode
  arrange(postcode) %>%
  ## match on geography info - postcode ##
  left_join(pc_lookup, by = "postcode") %>%
  # rename hb2018
  rename(hbpraccode = "hb2018") %>%
  #order variables
  select(
    gpprac,
    pc7,
    postcode,
    cluster,
    hbpraccode,
    hscp2018,
    ca2018
  ) %>%
  ## ca to lca code ##
  mutate(lca = ca_to_lca(ca2018))


## dummy postcodes ##
# set some known dummy practice codes to consistent Board codes
data <-
  data %>%
  mutate(
    hbpraccode = if_else(gpprac %in% c(99942, 99957, 99961, 99981, 99999), "S08200003", hbpraccode),
    hbpraccode = if_else(gpprac == 99995, "S08200001", hbpraccode)
  )



## save outfile ##
outfile <-
  data %>%
  # sort by gpprac
  arrange(gpprac) %>%
  # rename pc8 back - saved in output as pc8
  rename(pc8 = "postcode")

# .zsav
haven::write_sav(outfile, get_slf_gpprac_path(), compress = TRUE)

# .rds file
readr::write_rds(outfile, get_slf_gpprac_path(), compress = "gz")
