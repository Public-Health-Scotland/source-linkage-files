# Load phsopendata
# If it's not installed, install it from GitHub
library(phsopendata)

library(dplyr)
library(janitor)
library(fs)
library(haven)

latest_update <- "Jun_2022"
lookup_dir <- path("/conf/hscdiip/SLF_Extracts/Lookups")

# Retrieve the latest resource from the dataset
gp_clusters <- get_dataset("gp-practice-contact-details-and-list-sizes",
  max_resources = 1
) %>%
  clean_names() %>%
  # Get the code lookups so we have the names
  # Using the latest version of phsopendata for col_select
  tidylog::left_join(get_resource("944765d7-d0d9-46a0-b377-abb3de51d08e",
    col_select = c("HSCP", "HSCPName", "HB", "HBName")
  ) %>%
    clean_names()) %>%
  # Filter and save
  select(
    gpprac = practice_code,
    practice_name = gp_practice_name,
    postcode,
    cluster = gp_cluster,
    partnership = hscp_name,
    health_board = hb_name
  ) %>%
  # Sort for SPSS matching
  arrange(gpprac)

# Write as an SPSS file
write_sav(
  gp_clusters,
  path(lookup_dir,
    paste0("practice_details_", latest_update),
    ext = "zsav"
  ),
  compress = TRUE
)
