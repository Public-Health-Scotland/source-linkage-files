#' Check if chi is in a file
#' @description Check if chi is in a file, for pre-processing
#'
#' @param filename the name of file to check
#'
#' @return TRUE or FALSE
is_chi_in_file <- function(filename) {
  file_type <- tools::file_ext(filename)
  if (file_type == "csv") {
    data <- utils::read.csv(filename, nrow = 1)
    return(grepl("upi|chi", names(data), ignore.case = TRUE) %>% any())
  } else if (file_type == "parquet") {
    ds <- arrow::open_dataset(filename)
    return(grepl("upi|chi", ds$schema$names, ignore.case = TRUE) %>% any())
  } else {
    cli::cli_abort(stringr::str_glue("Unknown type: .{file_type}"))
  }
}
