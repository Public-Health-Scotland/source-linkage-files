################################################################################
# Name of file -  "dummy_targets.R"
#
# Description:
#       A small target example to run as test for BYOC.
#
#       To run the targets pipeline, please use:
#       targets::tar_make(script = 'dummy_targets.R')
#
################################################################################


library(logger)
library(targets)
# Stage 1 - Setup BYOC_MODE in targets -----------------------------------------
BYOC_MODE <- Sys.getenv("BYOC_MODE")
BYOC_MODE <- dplyr::case_when(
  BYOC_MODE %in% c("TRUE", "T", "true", "True") ~ TRUE,
  BYOC_MODE %in% c("FALSE", "F", "false", "False") ~ FALSE,
  TRUE ~ NA
)

if (BYOC_MODE) {
  targets::tar_config_set(store = "/sdl_byoc/byoc/output/_targets")
  logger::log_info("targets file location on Denodo")
} else {
  targets::tar_config_set(store = "/conf/sourcedev/Source_Linkage_File_Updates/_targets")
  logger::log_info("targets file location is local")
}


log_threshold(INFO)

# Phase II - Define functions to be used in the test
get_data <- function() {
  log_info("Starting the test: Data Generation")

  df <- data.frame(x = 1:10, y = runif(10))

  log_info("Data Generation complete")
  return(df)
}

analyze_data <- function(data) {
  log_info("Starting Data Analysis")

  res <- mean(data$y)

  log_info("Analysis complete")
  return(res)
}

# Stage 2 - Set up targets
#-------------------------------------------------------------------------------
list(
  tar_target(aaraw_data, get_data()),
  tar_target(aaverage_value, analyze_data(aaraw_data)),
  tar_target(aapipeline_status, {
    log_info("All targets completed successfully.")
    return("SUCCESS")
  })
)
#-------------------------------------------------------------------------------
## End of Targets pipeline ##
#-------------------------------------------------------------------------------
