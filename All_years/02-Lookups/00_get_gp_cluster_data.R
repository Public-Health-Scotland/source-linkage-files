# Load phsopendata
# If it's not installed, install it from GitHub
if (!require(phsopendata)) {
  # Check that we have remotes, if not install it first
  if (!("remotes" %in% installed.packages())) install.packages("remotes")

  remotes::install_github("Public-Health-Scotland/phsopendata")
  library(phsopendata)
}

library(dplyr)
library(janitor)
library(fs)
library(haven)

latest_update <- "Mar_2022"
lookup_dir <- path("/conf/hscdiip/SLF_Extracts/Lookups")

# Retrieve the latest resource from the dataset
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
    path(lookup_dir,
      paste0("practice_details_", latest_update),
      ext = "zsav"
    ),
    compress = TRUE
  )
