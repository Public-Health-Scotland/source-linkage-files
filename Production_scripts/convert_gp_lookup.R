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

## ca to lca code ##
# function will just be called once PR approved
ca_to_lca <- function(ca) {
  lca <- case_when(
    ca == "S12000033" ~ "01", # Aberdeen City
    ca == "S12000034" ~ "02", # Aberdeenshire
    ca == "S12000041" ~ "03", # Angus
    ca == "S12000035" ~ "04", # Argyll and Bute
    ca == "S12000026" ~ "05", # Scottish Borders
    ca == "S12000005" ~ "06", # Clackmannanshire
    ca == "S12000039" ~ "07", # West Dun
    ca == "S12000006" ~ "08", # Dumfies and Galloway
    ca == "S12000042" ~ "09", # Dundee City
    ca == "S12000008" ~ "10", # East Ayrshire
    ca == "S12000045" ~ "11", # East Dun
    ca == "S12000010" ~ "12", # East Lothian
    ca == "S12000011" ~ "13", # East Ren
    ca == "S12000036" ~ "14", # City of Edinburgh
    ca == "S12000014" ~ "15", # Falkirk
    ca == "S12000047" ~ "16", # Fife
    ca == "S12000049" ~ "17", # Glasgow City
    ca == "S12000017" ~ "18", # Highland
    ca == "S12000018" ~ "19", # Inverclyde
    ca == "S12000019" ~ "20", # Midlothian
    ca == "S12000020" ~ "21", # Moray
    ca == "S12000021" ~ "22", # North Ayrshire
    ca == "S12000050" ~ "23", # North Lan
    ca == "S12000023" ~ "24", # Orkney
    ca == "S12000048" ~ "25", # P & K
    ca == "S12000038" ~ "26", # Renfrewshire
    ca == "S12000027" ~ "27", # Shetland
    ca == "S12000028" ~ "28", # South Ayrshire
    ca == "S12000029" ~ "29", # South Lan
    ca == "S12000030" ~ "30", # Stirling
    ca == "S12000040" ~ "31", # West Lothian
    ca == "S12000013" ~ "32" # Na h-Eileanan Siar
  )
  return(lca)
}

data <-
  data %>%
  mutate(lca = ca_to_lca(ca2018))


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
