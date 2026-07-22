##########################
# Convert uk_postcode files
#
# Original Author - Zihao
# Original Date - July 2026
# Written/run on - R Posit
# Version of R - 4.5.1
##########################

# update uk postcode directory/list first, then move uk postcode files

## Stage 1 - Setup environment ----
# load package
devtools::load_all()

## Stage 2 - update uk postcode files ---------------
update_uk_postcode_directory()

## END OF SCRIPT ##
