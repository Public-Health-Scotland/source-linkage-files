#' Write Console Output to File
#'
#' @description Initialises logger for run_episode_file_fy.R and run_individual_file_fy.R.
#'
#' @param console_outputs If TRUE, capture console output and messages to file.
#' @param file_type Type of file being processed: "episode", "individual", or "targets".
#' @param year Financial year.
#'
#' @export
write_console_output <- function(console_outputs = TRUE,
                                 file_type = c("episode", "individual", "targets"),
                                 year = NULL) {
  if (!console_outputs) {
    return(invisible(NULL))
  }

  file_type <- match.arg(file_type)

  # Update information
  update <- latest_update()
  update_year <- as.integer(substr(phsmethods::extract_fin_year(end_date()), 1, 4))
  update_quarter <- qtr()

  # Output directory path
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

#' Log Episode File Messages
#'
#' @param stage Stage of episode file (run_episode_file_fy.R) creation.
#' @param year Financial year.
#'
#' @export
log_ep_message <- function(stage = c("start", "read_data", "creating", "complete"),
                           year) {
  stage <- match.arg(stage)

  messages <- list(
    start = "Starting episode file creation for ep_{year}",
    read_data = "Reading processed data from source extracts for year {year}",
    creating = "Creating episode file and running tests for year {year}",
    complete = "Episode file creation complete for year {year}"
  )

  logger::log_info(stringr::str_glue(messages[[stage]]))
}

#' Log Individual File Messages
#'
#' @param stage Stage of individual file (run_individual_file_fy.R) creation.
#' @param year Financial year.
#'
#' @export
log_ind_message <- function(stage = c("start", "read_data", "creating", "complete"),
                            year) {
  stage <- match.arg(stage)

  messages <- list(
    start = "Starting individual file creation for ind_{year}",
    read_data = "Reading episode file for year {year}",
    creating = "Creating individual file and running tests for year {year}",
    complete = "Individual file creation complete for year {year}"
  )

  logger::log_info(stringr::str_glue(messages[[stage]]))
}

#' Log Targets Messages
#'
#' @param stage Stage of targets (run_targets_fy.R) creation.
#'
#' @export
log_tar_message <- function(stage = c("start", "combining_tests", "all_complete")) {
  stage <- match.arg(stage)

  messages <- list(
    start = "Starting targets pipeline",
    combining_tests = "Combining test results",
    all_complete = "All processing complete"
  )

  logger::log_info(messages[[stage]])
}

#' Log SLF Intermediate Processing
#'
#' @description Logs messages for read, process, and test stages/scripts
#'
#' @param stage Character: "read", "process", or "test".
#' @param status Character: "start" or "complete".
#' @param type Character: The name of the data (e.g., "Acute", "A&E").
#' @param year Character: The financial year.
#' @param ... Additional arguments for string interpolation.
#'
#' @export
log_slf_event <- function(stage = c("read", "process", "test"),
                          status = c("start", "complete"),
                          type,
                          year,
                          ...) {
  stage <- match.arg(stage)
  status <- match.arg(status)

  # List of message templates
  messages <- list(
    read = list(
      start    = "Reading {year} {type} data from denodo",
      complete = "Finished reading {year} {type} data"
    ),
    process = list(
      start    = "Processing {year} {type} data",
      complete = "Finished processing {year} {type} data"
    ),
    test = list(
      start    = "Running process test on {year} {type} data",
      complete = "Completed tests on {year} {type} data"
    )
  )

  msg <- stringr::str_glue(messages[[stage]][[status]])

  logger::log_info(msg)
}

#' Log Create Episode File (create_episode_file.R) Stages
#'
#' @param sub_stage Character: The name of the specific process (e.g., "Join cohort lookups").
#' @param status Character: "started" or "finished".
#' @param year Character: The financial year.
#'
#' @export
log_ep_substage <- function(sub_stage, status, year) {
  msg <- stringr::str_glue("Episode File: {sub_stage} {status} for {year}")

  logger::log_info(msg)
}

#' Log Create Individual File (create_individual_file.R) Stages
#'
#' @param sub_stage Character: The name of the specific process (e.g., "Add cij columns").
#' @param status Character: "started" or "finished".
#' @param year Character: The financial year.
#'
#' @export
log_ind_substage <- function(sub_stage, status, year) {
  msg <- stringr::str_glue("Individual File: {sub_stage} {status} for {year}")

  logger::log_info(msg)
}
