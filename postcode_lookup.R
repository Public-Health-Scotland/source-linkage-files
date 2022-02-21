#####################################################
# Postcode Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################

library(dplyr)
library(tidyr)
library(haven)


## read data in ##

# postcode data
pc_file <- read_spd_file()

# simd data
read_simd_file <- function(file) {
  simd_path <- fs::path(get_lookups_dir(), "Deprivation", file)
  # If given a sav extension (or other), swap it for rds
  simd_path <- fs::path_ext_set(simd_path, "rds")
  # Check if the file exists and we can read it
  if (!fs::file_access(simd_path, "read")) {
    rlang::abort(message = "Couldn't read the simd file")
  }
  return(simd_path)
}
simd_file <- readr::read_rds(read_simd_file(file = "postcode_2021_2_simd2020v2.rds"))

# locality
read_locality_file <- function(file) {
  locality_path <-
    fs::path(get_lookups_dir(), "Geography", "HSCP Locality", file)
  # If given a sav extension (or other), swap it for rds
  locality_path <- fs::path_ext_set(locality_path, "rds")
  # Check if the file exists and we can read it
  if (!fs::file_access(locality_path, "read")) {
    rlang::abort(message = "Couldn't read the locality file")
  }
  return(locality_path)
}
locality_file <- readr::read_rds(read_locality_file("HSCP Localities_DZ11_Lookup_20200825.rds"))


## clean up data ##

# arrange pc lookups based on pc7
pc_file <-
  pc_file %>%
  arrange(pc7)

# arrange simd based on pc7
simd_file <-
  simd_file %>%
  arrange(pc7)

# join data together by pc7
data <-
  pc_file %>%
  left_join(simd_file, by = "pc7") %>%
  # sort by DataZone2011
  rename(datazone2011 = "datazone2011.x") %>%
  arrange(datazone2011)


# rename and drop variable in locality
locality_file <-
  locality_file %>%
  rename(locality = "hscp_locality") %>%
  # remove ca2019name hscp2019name hb2019name
  select(-ca2019name, -hscp2019name, -hb2019name) %>%
  # arrange by datazone2011
  arrange(datazone2011) %>%
  # recode missing locality
  mutate(locality = replace_na(locality, "No Locality Information"))


## LCA code ##

locality_file <-
  locality_file %>%
  mutate(lca = ca_to_lca(ca2019))



## save file ##

data <-
  data %>%
  # rename pc7
  rename(
    postcode = "pc7",
    simd2020v2_rank = "simd2020v2_rank.x"
  ) %>%
  # select variables for outfile
  select(
    datazone2011,
    postcode,
    simd2020v2_rank,
    simd2020v2_sc_decile,
    simd2020v2_sc_quintile,
    simd2020v2_hb2019_decile,
    simd2020v2_hb2019_quintile,
    simd2020v2_hscp2019_decile,
    simd2020v2_hscp2019_quintile,
    ur8_2016,
    ur6_2016,
    ur3_2016,
    ur2_2016
  )

# join data and locality files by datazone2011
outfile <-
  data %>%
  left_join(locality_file, by = "datazone2011") %>%
  select(
    postcode,
    hb2018,
    hscp2018,
    ca2018,
    lca,
    locality,
    datazone2011,
    hb2019,
    ca2019,
    hscp2019,
    simd2020v2_rank,
    simd2020v2_sc_decile,
    simd2020v2_sc_quintile,
    simd2020v2_hb2019_decile,
    simd2020v2_hb2019_quintile,
    simd2020v2_hscp2019_decile,
    simd2020v2_hscp2019_quintile,
    ur8_2016,
    ur6_2016,
    ur3_2016,
    ur2_2016
  )


# .zsav
haven::write_sav(outfile, get_slf_postcode_path(), compress = TRUE)

# .rds file
readr::write_rds(outfile, get_slf_postcode_path(), compress = "gz")
