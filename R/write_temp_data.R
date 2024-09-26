#' Write a temp data to disk in parquet format for debugging purpose
#'
#' @description Write a temp data in parquet format to disk for debugging purpose.
#' @param data The data to be written
#' @param year year variable
#' @param file_name The file name to be written
#' @param test_mode Boolean type to determine whether it is in a test mode
#'
#' @return the data for next step as a [tibble][tibble::tibble-package].
#' @export
write_temp_data <-
  function(data, year, file_name, test_mode) {
    full_file_name <- stringr::str_glue("{file_name}.parquet")
    file_path <- file.path(get_year_dir(year),
                           full_file_name) %>%
      add_test_to_filename(test_mode)

    cli::cli_alert_info(stringr::str_glue("Writing {full_file_name} to disk started at {Sys.time()}"))

    write_file(data,
               path = file_path)

    return(data)
  }


#' Add "TEST-" to the file name of a file Path
#'
#' @description This function takes a full file path and adds "TEST-" as a prefix to the file name, while preserving the directory structure.
#'
#' @param file_path A character string representing the full path to a file (e.g., "/path/to/folder/data.csv").
#' @return A character string representing the modified file path with "TEST-" added to the file name.
#' @export
#' @examples
#' # Example usage
#' file_path <- "/conf/folder1/folder2/data.csv"
#' new_file_path <- add_test_to_filename(file_path)
#' print(new_file_path)  # Outputs: "/conf/folder1/folder2/TEST-data.csv"
add_test_to_filename <- function(file_path, test_mode) {
  if (test_mode) {
    # Extract the directory and the file name separately
    dir_path <- dirname(file_path)
    file_name <- basename(file_path)

    # Add "TEST-" to the file name
    new_file_name <- paste0("TEST-", file_name)

    # Reconstruct the new file path
    new_file_path <- file.path(dir_path, new_file_name)

    return(new_file_path)
  } else{
    return(file_path)
  }
}
