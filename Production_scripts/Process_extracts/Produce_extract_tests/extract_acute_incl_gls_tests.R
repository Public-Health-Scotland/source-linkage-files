####################################################

# Name of file - B01b-Acute-tests.R
# Original Authors - Jennifer Thom
# Original Date - March 2022
#
# Written/run on - RStudio Server
# Version of R - 3.6.1
#
# Description - Produce tests for source linkage files
# postcode lookup file.

#####################################################

# Load packages
library(createslf)
library(openxlsx)
library(slfhelper)


# Read in Data---------------------------------------

# Read current SLF episode file and filter for 01B and GLS records
slf_ep_1920 <- read_slf_episode("1920", recid = c("01B", "GLS"))


# Create new and old dataframes with measures for testing
# To compare new slf extract to current file in hscdiip
new_tests <- produce_source_acute_tests(readr::read_rds(get_source_extract_path(year, "Acute")))
old_tests <- produce_source_acute_tests(slf_ep_1920)


# Create tests-------------------------------------------

# Compare new and old outputs
comparison <- produce_test_comparison(old_tests, new_tests)


# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook

# Load excel workbook
wb <- loadWorkbook(fs::path(
  get_slf_dir(), "Tests",
  paste0(latest_update(), "_tests2.xlsx")
))
# add a new sheet for tests
addWorksheet(wb, "source_gpprac_lookup")
# write comparison output to new sheet
writeData(
  wb,
  "source_gpprac_lookup",
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
                   get_slf_dir(), "Lookups",
                   paste0("source_GPprac_lookup_", latest_update(), "_tests",
                          ext = ".zsav"
                   )
                 ),
                 compress = TRUE
)


## END OF SCRIPT ##
