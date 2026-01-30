#' Write Console Output to File
#'
#' @description Initialises logger to log texts and console output to file
#'
#' @param console_outputs If TRUE, capture console output and messages to file.
#' @param file_type Type of file being processed: "episode", "individual", or "targets".
#' @param year Financial year.

write_console_output <- function(console_outputs = TRUE,
                                 file_type = c("episode", "individual", "targets"),
                                 year = NULL) {
  if (!console_outputs) {
    return(invisible(NULL))
  }

  file_type <- match.arg(file_type)

  # update information
  update <- latest_update()
  update_year <- as.integer(substr(phsmethods::extract_fin_year(end_date()), 1, 4))
  update_quarter <- qtr()

  # output directory path
  con_output_dir <- file.path(
    "/conf/sourcedev/Source_Linkage_File_Updates/_console_output",
    update_year,
    update_quarter
  )
  if (!dir.exists(con_output_dir)) {
    dir.create(con_output_dir, recursive = TRUE)
  }

  base_filename <- switch(file_type,
    "episode" = stringr::str_glue("ep_{year}_{update}_update"),
    "individual" = stringr::str_glue("ind_{year}_{update}_update"),
    "targets" = stringr::str_glue("targets_console_{update}_update")
  )

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

  # Add logger appender to write to file
  logger::log_appender(logger::appender_tee(file_path), index = 2)
  logger::log_info("Console output will be saved to: {file_path}")

  invisible(file_path)
}

# Log strings - this makes it easier to maintain and update logger messages
# Episode file messages
ep_messages <- list(
  start = "Starting episode file creation for ep_{year}",
  read_data = "Reading processed data from source extracts for year {year}",
  creating = "Creating episode file and running tests for year {year}",
  complete = "Episode file creation complete for year {year}"
)

# Individual file messages
ind_messages <- list(
  start = "Starting individual file creation for ind_{year}",
  read_data = "Reading episode file for year {year}",
  creating = "Creating individual file and running tests for year {year}",
  complete = "Individual file creation complete for year {year}"
)

# Targets messages
tar_messages <- list(
  start = "Starting targets pipeline",
  combining_tests = "Combining test results",
  all_complete = "All processing complete"
)

# Logger helper functions
log_ep_message <- function(stage = c("start", "read_data", "creating", "complete"),
                           year) {
  stage <- match.arg(stage)
  message <- ep_messages[[stage]]

  logger::log_info(stringr::str_glue(message))
}

log_ind_message <- function(stage = c("start", "read_data", "creating", "complete"),
                            year) {
  stage <- match.arg(stage)
  message <- ind_messages[[stage]]

  logger::log_info(stringr::str_glue(message))
}

log_tar_message <- function(stage = c("start", "combining_tests", "all_complete")) {
  stage <- match.arg(stage)
  message <- tar_messages[[stage]]

  logger::log_info(message)
}
