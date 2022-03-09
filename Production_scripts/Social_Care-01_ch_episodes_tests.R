####################################################

# Name of file - sc_ch_episodes_tests.R
# Original Authors - Jennifer Thom
# Original Date - January 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for social care - care home episodes file.

####################################################

# Packages
library(createslf)
library(openxlsx)


# Read in Data---------------------------------------

# Create new and old dataframes with measures for testing
new_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path()))
old_tests <- produce_sc_ch_episodes_tests(haven::read_sav(get_sc_ch_episodes_path(update = previous_update())))

# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook

# Load excel workbook
wb <- loadWorkbook(fs::path(
  get_slf_dir(), "Tests",
  paste0(latest_update(), "_tests.xlsx")
))
# add a new sheet for tests
addWorksheet(wb, "all_ch_episodes")
# write comparison output to new sheet
writeData(
  wb,
  "all_ch_episodes",
  comparison
)
# save output
saveWorkbook(wb,
  fs::path(
    get_slf_dir(), "Tests",
    paste0(latest_update(), "_tests.xlsx")
  ),
  overwrite = TRUE
)


# Save output as zsav
# This can be removed once confirmed excel workbook is okay
haven::write_sav(comparison,
  path(
    get_slf_dir(), "Social_care",
    paste0("all_ch_episodes_", latest_update(), "_tests",
      ext = ".zsav"
    )
  ),
  compress = TRUE
)


## END OF SCRIPT ##
