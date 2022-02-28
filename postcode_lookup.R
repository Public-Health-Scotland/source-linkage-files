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
pc_file <- readr::read_rds(read_spd_file()) %>%
  select(pc7,
         datazone2011,
         ur8_2016,
         ur6_2016,
         ur3_2016,
         ur2_2016)

# simd data
simd_file <- readr::read_rds(read_simd_file(file = "postcode_2021_2_simd2020v2.rds")) %>%
  select(pc7,
         datazone2011,
         simd2020v2_rank,
         simd2020v2_sc_decile,
         simd2020v2_sc_quintile,
         simd2020v2_hb2019_decile,
         simd2020v2_hb2019_quintile,
         simd2020v2_hscp2019_decile,
         simd2020v2_hscp2019_quintile)

# locality
locality_file <- readr::read_rds(read_locality_file("HSCP Localities_DZ11_Lookup_20200825.rds")) %>%
  select(datazone2011,
         hscp_locality,
         hscp2019,
         hscp2018,
         ca2018,
         ca2019,
         hb2019,
         hb2018)



## clean up data ##

# join data together by pc7
data <-
  pc_file %>%
  left_join(simd_file, by = c("pc7", "datazone2011")) %>%
  rename(postcode = "pc7")


# rename and drop variable in locality
locality_file <-
  locality_file %>%
  rename(locality = "hscp_locality") %>%
  # arrange by datazone2011
  arrange(datazone2011) %>%
  # recode missing locality
  mutate(locality = replace_na(locality, "No Locality Information"))


## LCA code ##

locality_file <-
  locality_file %>%
  mutate(lca = ca_to_lca(ca2019))



## outfile ##

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


## save ##

# .zsav
haven::write_sav(outfile, get_slf_postcode_path(), compress = TRUE)

# .rds file
readr::write_rds(outfile, get_slf_postcode_path(), compress = "gz")
