#' Write Console Output to File
#'
#' @description Sets up logger to capture output and log messages to file.
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

  # Determine if this is a BYOC run or local run. Default to FALSE (local run)
  is_byoc <- exists("BYOC_MODE") && isTRUE(BYOC_MODE)

  # Configure logger based on environment
  if (is_byoc) {
    # BYOC run = INFO level
    logger::log_threshold(logger::INFO)
  } else {
    # Local run = DEBUG level
    logger::log_threshold(logger::DEBUG)
  }

  # Set logger format
  logger::log_formatter(logger::formatter_glue_or_sprintf)
  logger::log_layout(logger::layout_glue_colors)

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

  # Log the start
  logger::log_info("Running in {ifelse(is_byoc, 'BYOC', 'LOCAL')} mode")
  logger::log_info("Console output will be saved to: {file_path}")

  invisible(file_path)
}
