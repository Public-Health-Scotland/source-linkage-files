#' Write Console Output to File
#'
#' @description Sets up sink to capture console output and messages to .txt file.
#'
#' @param console_outputs If TRUE, capture console output and messages to .txt file.
#' @param file_type Type of file being processed: "episode", "individual", or "targets".
#' @param year Financial year.
#'
#' @examples
#' write_console_output(console_outputs = TRUE, file_type = "episode", year = "2324")
#' write_console_output(console_outputs = TRUE, file_type = "individual", year = "2324")
#' write_console_output(console_outputs = TRUE, file_type = "targets")
#'
#' @export
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

  # sink connection
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
