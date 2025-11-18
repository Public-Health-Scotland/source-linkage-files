################################################################################
# Name of file -  Run_all_targets.R
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
#     This script works together to run with the "_Targets.R" script. It is
#     designed to run the targets pipeline to process each extract and get this
#     ready for combining together in the episode file. The pipeline takes
#     approximately 1hr 30mins to run but this will depend on the number of years
#     running.
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
library(createslf)

# devtools::load_all()

# Specify TRUE/FALSE for saving the console output to disk
# Default set as TRUE
console_outputs <- TRUE

# -------------------------------------------------------------------------------
# save console outputs if `console_outputs == TRUE`
if (console_outputs) {
  update <- latest_update()
  update_year <- as.integer(substr(phsmethods::extract_fin_year(end_date()), 1, 4))
  update_quarter <- qtr()

  con_output_dir <- file.path(
    "/conf/sourcedev/Source_Linkage_File_Updates/_console_output",
    update_year,
    update_quarter
  )
  if (!dir.exists(con_output_dir)) {
    dir.create(con_output_dir, recursive = TRUE)
  }

  base_filename <- stringr::str_glue("targets_console_{update}_update")
  existing_files <- list.files(
    path = con_output_dir,
    pattern = stringr::str_glue("^{base_filename}_[0-9]+\\.txt$"),
    full.names = FALSE
  )
  if (length(existing_files) == 0) {
    increment <- 1
  } else {
    numbers <- stringr::str_extract(existing_files, "[0-9]+(?=\\.txt$)") %>%
      as.integer()
    increment <- max(numbers, na.rm = TRUE) + 1
  }

  file_name <- stringr::str_glue("{base_filename}_{increment}.txt")
  file_path <- file.path(con_output_dir, file_name)

  con <- file(file_path, open = "wt")

  sink(con, type = "output", split = TRUE)
  sink(con, type = "message", append = TRUE)

  on.exit(
    {
      sink(type = "message")
      sink(type = "output")
      close(con)
      cat("\n✓ Console output saved to:", file_path, "\n")
    },
    add = TRUE
  )
}

# Run the targets pipeline "_Targets.R"
#-------------------------------------------------------------------------------

# tar_make() will run the pipeline and use crew() for parallel processing.
tar_make()

# Run combine_tests() for outputting the test workbooks.
createslf::combine_tests()

#-------------------------------------------------------------------------------

# END OF SCRIPT #

#-------------------------------------------------------------------------------
