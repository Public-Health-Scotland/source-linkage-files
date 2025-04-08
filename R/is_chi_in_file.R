#' Check if chi is in a file
#' @description Check if chi is in a file, for pre-processing
#'
#' @param filename the name of file to check
#'
#' @return TRUE or FALSE
is_chi_in_file <- function(filename) {
  data <- read.csv(filename, nrow = 1)
  return(grepl("UPI", names(data)) %>% any())
}
