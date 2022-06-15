#####################################################
# GP Cluster Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - NHS open data, open data
# Description - Match data, clean
#               outputs GP Cluster Lookup
#####################################################

# Load packages
library(dplyr)
library(createslf)
library(janitor)

latest_update <- "Mar_2022"


# Read in data---------------------------------------

gp_clusters <- phsopendata::get_dataset("gp-practice-contact-details-and-list-sizes", max_resources = 20) %>%
  clean_names()

code_lookups <- phsopendata::get_resource("944765d7-d0d9-46a0-b377-abb3de51d08e",
  col_select = c("HSCP", "HSCPName", "HB", "HBName")
) %>%
  clean_names()


# Match data---------------------------------------

matched_gp_clusters <- gp_clusters %>%
  left_join(code_lookups, by = c("hb", "hscp"))


# Data Cleaning---------------------------------------

gp_clusters_clean <- matched_gp_clusters %>%
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
  filter(!is.na(cluster)) %>%
  # format practice name text
  mutate(practice_name = stringr::str_to_title(practice_name)) %>%
  # format postcode
  mutate(postcode = phsmethods::format_postcode(postcode)) %>%
  # keep distinct gpprac
  distinct(gpprac, .keep_all = TRUE)



# Save Outfile---------------------------------------

gp_clusters_clean %>%
  # .zsav
  write_sav(get_slf_gp_cluster_path(update = latest_update, ext = "zsav", check_mode = "write")) %>%
  # .rds file
  write_rds(get_ch_costs_path(update = latest_update, check_mode = "write"))


## End of Script ---------------------------------------
