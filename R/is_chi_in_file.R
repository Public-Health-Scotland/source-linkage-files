#' Check if chi is in a file
#' @description Check if chi is in a file, for pre-processing
#'
#' @param filename the name of file to check
#'
#' @return TRUE or FALSE
is_chi_in_file <- function(filename) {
  file_type <- tools::file_ext(filename)
  if(file_type == "csv"){
    data <- read.csv(filename, nrow = 1)
    return(grepl("UPI", names(data)) %>% any())
  }else if(file_type == "parquet"){
    ds <- arrow::open_dataset(filename)
    return(grepl("UPI", names(ds$schema$names)) %>% any())
  }else{
    cli::cli_abort(stringr::str_glue("Unknown type: .{file_type}"))
  }
}
