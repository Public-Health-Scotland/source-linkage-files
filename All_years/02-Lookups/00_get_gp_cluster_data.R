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


latest_update <- "Dec_2021"

# Retrieve the latest resource from the dataset
gp_data <- get_dataset("gp-practice-contact-details-and-list-sizes",
  max_resources = 1
) %>%
  clean_names()

# Filter to relevant variables
gp_data <- gp_data %>%
  select(
    practice_code,
    practice_name = gp_practice_name,
    hb,
    hscp,
    postcode,
    cluster = gp_cluster
  )

gp_data %>%
  rename(gpprac = practice_code) %>%
  arrange(gpprac) %>%
  write_sav(path(lookup_dir,
    paste0("practice_details_", latest_update),
    ext = "zsav"
  ),
  compress = TRUE
  )
