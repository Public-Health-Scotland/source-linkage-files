################################################################################
# Name of file -  Run_targets_2425.R
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - March 2023
# Written/run on - R Posit
# Version of R - 4.4.2
#
# Description:
#     This script can run in the console or as a workbench job. Please specify a
#     Posit workbench session of 8CPU and 128GB.
#
#     This script will run all targets in the "_Targets.R" script containing
#     "2425" data objects. To run all targets for all years please see the script
#     "run_all_targets".
#
#     This is useful if only one year needed to run.
#
#     Targets objects will be stored in:
#         "/conf/sourcedev/Source_Linkage_File_Updates/_targets/objects"
#     and each processed extract will be written to disk in each year specific
#     folder ready for creating the episode file e.g:
#         "/conf/sourcedev/Source_Linkage_File_Updates/1920"
#
#     To run specific objects, please manually remove this from the objects
#     folder and re-run this script.
#
################################################################################

# Setup-------------------------------------------------------------------------
library(targets)

year <- "2425"

# Run targets pipeline
#-------------------------------------------------------------------------------

# use targets for the process until testing episode files
tar_make(
  # it does not recognise `contains(year)`
  names = (targets::contains("2425"))
)

#-------------------------------------------------------------------------------

# END OF SCRIPT #

#-------------------------------------------------------------------------------
