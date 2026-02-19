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

# Stage 1 - Set up
#-------------------------------------------------------------------------------
# Phase I - Load the required libraries
library(targets)
# tar_config_set(store = "dummy_store")
library(logger)

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
