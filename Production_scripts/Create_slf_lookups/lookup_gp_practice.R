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
library(createslf)

# Read in data---------------------------------------

# Retrieve the latest resource from the dataset
opendata <-
  phsopendata::get_dataset("gp-practice-contact-details-and-list-sizes",
    max_resources = 20
  ) %>%
  janitor::clean_names() %>%
  left_join(
    phsopendata::get_resource(
      "944765d7-d0d9-46a0-b377-abb3de51d08e",
      col_select = c("HSCP", "HSCPName", "HB", "HBName")
    ) %>%
      janitor::clean_names(),
    by = c("hb", "hscp")
  ) %>%
  # select variables
  select(
    gpprac = practice_code,
    practice_name = gp_practice_name,
    postcode,
    cluster = gp_cluster,
    partnership = hscp_name,
    health_board = hb_name
  ) %>%
  # drop NA cluster rows
  tidyr::drop_na(cluster) %>%
  # format practice name text
  mutate(practice_name = stringr::str_to_title(practice_name)) %>%
  # format postcode
  mutate(postcode = phsmethods::format_postcode(postcode)) %>%
  # keep distinct gpprac
  distinct(gpprac, .keep_all = TRUE) %>%
  # Sort for SPSS matching
  arrange(gpprac) %>%
  # Write rds file
  write_rds(get_practice_details_path(check_mode = "write"))


# Read Lookup files ---------------------------------------
# gp lookup
gpprac_ref_file <-
  readr::read_rds(get_gpprac_ref_path()) %>%
  # select only praccode and postcode
  select(
    gpprac = praccode,
    postcode
  )

# postcode lookup
spd_file <- readr::read_rds(get_spd_path()) %>%
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
  left_join(opendata, gpprac_ref_file, by = c("gpprac", "postcode")) %>%
  # match on geography info - postcode
  left_join(spd_file, by = "postcode") %>%
  # rename hb2018
  rename(hbpraccode = "hb2018") %>%
  # order variables
  select(
    gpprac,
    pc7,
    postcode,
    cluster,
    hbpraccode,
    hscp2018,
    ca2018
  ) %>%
  # convert ca to lca code
  mutate(lca = convert_ca_to_lca(ca2018)) %>%
  # set some known dummy practice codes to consistent Board codes
  mutate(
    hbpraccode = if_else(
      gpprac %in% c(99942, 99957, 99961, 99981, 99999),
      "S08200003",
      hbpraccode
    ),
    hbpraccode = if_else(gpprac == 99995, "S08200001", hbpraccode)
  ) %>%
  # sort by gpprac
  arrange(gpprac) %>%
  # rename pc8 back - saved in output as pc8
  rename(pc8 = "postcode")


## save outfile ---------------------------------------

# Save .rds file
gpprac_slf_lookup %>%
  write_rds(get_slf_gpprac_path(check_mode = "write"))


## End of Script ---------------------------------------
