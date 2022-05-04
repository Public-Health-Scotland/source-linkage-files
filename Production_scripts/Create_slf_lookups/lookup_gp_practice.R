#####################################################
# GP Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################

## packages ##
library(dplyr)
library(tidyr)
library(haven)
library(phsopendata)
library(janitor)
library(fs)

## get data ##

# use `00_get_gp_cluster_data.R`- draws from open data
# latest update date
latest_update <- latest_update()

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
      get_lookups_dir(),
      paste0("practice_details_", latest_update),
      ext = "zsav"
    ),
    compress = TRUE
  )


# gp lookup
gp <-
  haven::read_sav(fs::path(get_lookups_dir(), "National Reference Files", "gpprac.sav")) %>%
  # select only praccode and postcode
  select(
    praccode,
    postcode
  ) %>%
  # sort by praccode
  arrange(praccode) %>%
  # rename praccode to allow join
  rename(gpprac = "praccode")

## match cluster information onto the practice reference list ##
data <-
  opendata %>%
  # join cluster and gp data
  left_join(gp, by = c("gpprac", "postcode")) %>%
  # sort by postcode
  arrange(postcode)

## match on geography info ##

# postcode lookup
pc <- read_spd_file() %>%
  select(
    pc7,
    pc8,
    hb2018,
    hscp2018,
    ca2018
  ) %>%
  # rename pc8
  rename(postcode = "pc8")

data <-
  data %>%
  # join data and postcode data
  left_join(pc, by = "postcode") %>%
  # rename hb2018
  rename(hbpraccode = "hb2018") %>%
  select(
    gpprac,
    pc7,
    postcode,
    cluster,
    hbpraccode,
    hscp2018,
    ca2018
  )

## council area code ##
data <-
  data %>%
  mutate(lca = convert_ca_to_lca(ca2018))


## dummy postcodes ##
# set some known dummy practice codes to consistent Board codes
data <-
  data %>%
  mutate(
    hbpraccode = case_when(
      gpprac %in% c(99942, 99957, 99961, 99981, 99999) ~ "S08200003",
      gpprac == 99995 ~ "S08200001",
      TRUE ~ hbpraccode
    )
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
