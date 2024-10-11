#' Write a temp data to disk in parquet format for debugging purpose
#'
#' @description Write a temp data in parquet format to disk for debugging purpose.
#' @param data The data to be written
#' @param year year variable
#' @param file_name The file name to be written
#' @param write_temp_to_disk Boolean type, write temp data to disk or not
#'
#' @return the data for next step as a [tibble][tibble::tibble-package].
#' @export
write_temp_data <-
  function(data, year, file_name, write_temp_to_disk) {
    if (write_temp_to_disk) {
      full_file_name <- stringr::str_glue("{file_name}.parquet")
      file_path <- file.path(get_year_dir(year),
                             full_file_name)

      cli::cli_alert_info(stringr::str_glue("Writing {full_file_name} to disk started at {Sys.time()}"))

      write_file(data,
                 path = file_path)
    }
    return(data)
  }


#' Read a temp data from disk for debugging purpose
#'
#' @description Read a temp data to disk for debugging purpose.
#' @param year year variable
#' @param file_name The file name to be read
#'
#' @return the data for next step as a [tibble][tibble::tibble-package].
#' @export
read_temp_data <- function(year, file_name) {
  full_file_name <- stringr::str_glue("{file_name}.parquet")
  file_path <- file.path(get_year_dir(year),
                         full_file_name)

  return(read_file(file_path))
}

#' Clean temp data from disk
#'
#' @description Clean temp data from disk to save storage.
#' @param year year variable
#' @param file_type ep or ind files
#'
#' @return the data for next step as a [tibble][tibble::tibble-package].
#' @export
clean_temp_data <- function(year, file_type = c("ep", "ind")) {
  list.files(path = get_year_dir(year),
             pattern = stringr::str_glue("^{file_type}_temp")) %>%
    file.remove()
}
