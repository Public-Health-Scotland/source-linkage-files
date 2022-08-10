####################################################
# Name of file - extract_chi_ltc_tests.R
# Original Authors - Bateman McBride
# Original Date - August 2022
# Written/run on - RStudio Server
# Version of R - 3.6.1
# Description - Produce tests for source linkage files:
#               LTC file received from IT.
#####################################################

year <- check_year_format("1920")

new_data <- readr::read_rds(get_ltcs_path(year))

# Find and flag any duplicate chis and chi/postcode combinations
duplicates <- new_data %>%
  dplyr::summarise(duplicate_chi = nrow(new_data) - dplyr::n_distinct(chi)) %>%
  tidyr::pivot_longer(
    cols = tidyselect::everything(),
    names_to = "measure",
    values_to = "value"
  )

# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(duplicates, "chi_ltc_extract")
