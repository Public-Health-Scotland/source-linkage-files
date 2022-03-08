#####################################################
# Postcode Lookup
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - Postcode Data
# Description -  Build the Postcode Lookup
#####################################################

# Packages
  library(dplyr)
  library(tidyr)
  library(haven)
  library(createslf)


# Read lookup files -------------------------------------------------------

# postcode data
pc_file <- readr::read_rds(read_spd_file()) %>%
  select(
    pc7,
    matches("datazone\\d{4}$"),
    matches("hb\\d{4}$"),
    matches("hscp\\d{4}$"),
    matches("ca\\d{4}$"),
    matches("ur8_\\d{4}$"),
    matches("ur6_\\d{4}$"),
    matches("ur3_\\d{4}$"),
    matches("ur2_\\d{4}$")
  ) %>%
  mutate(lca = ca_to_lca(ca2019))

# simd data
simd_file <- readr::read_rds(read_simd_file(file = "postcode_2021_2_simd2020v2.rds")) %>%
  select(
    pc7,
    matches("simd\\d{4}.?.?_rank"),
    matches("simd\\d{4}.?.?_sc_decile"),
    matches("simd\\d{4}.?.?_sc_quintile"),
    matches("simd\\d{4}.?.?_hb\\d{4}_decile"),
    matches("simd\\d{4}.?.?_hb\\d{4}_quintile"),
    matches("simd\\d{4}.?.?_hscp\\d{4}_decile"),
    matches("simd\\d{4}.?.?_hscp\\d{4}_quintile")
  )

# locality
locality_file <- readr::read_rds(read_locality_file(file = "HSCP Localities_DZ11_Lookup_20200825.rds")) %>%
  select(
    locality = hscp_locality,
    matches("datazone\\d{4}$")
  ) %>%
  mutate(locality = replace_na(locality, "No Locality Information"))


# Join data together  -----------------------------------------------------
data <-
  left_join(pc_file, simd_file, by = "pc7") %>%
  rename(postcode = "pc7") %>%
  left_join(locality_file, by = "datazone2011")


# Finalise output -----------------------------------------------------

outfile <-
  data %>%
  select(
    postcode,
    lca,
    locality,
    matches("datazone\\d{4}$")[1],
    matches("hb\\d{4}$(?:20[2-9]\\d)|(?:201[89])$"),
    matches("hscp\\d{4}$(?:20[2-9]\\d)|(?:201[89])$"),
    matches("ca\\d{4}$(?:20[2-9]\\d)|(?:201[89])$"),
    matches("simd\\d{4}.?.?_rank"),
    matches("simd\\d{4}.?.?_sc_decile"),
    matches("simd\\d{4}.?.?_sc_quintile"),
    matches("simd\\d{4}.?.?_hb\\d{4}_decile"),
    matches("simd\\d{4}.?.?_hb\\d{4}_quintile"),
    matches("simd\\d{4}.?.?_hscp\\d{4}_decile"),
    matches("simd\\d{4}.?.?_hscp\\d{4}_quintile"),
    matches("ur8_\\d{4}$"),
    matches("ur6_\\d{4}$"),
    matches("ur3_\\d{4}$"),
    matches("ur2_\\d{4}$")
  )


# Save out ----------------------------------------------------------------

# .zsav
haven::write_sav(outfile, get_slf_postcode_path(), compress = TRUE)

# .rds file
readr::write_rds(outfile, get_slf_postcode_path(), compress = "gz")
