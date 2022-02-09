#' Check for NA or blank values in a character vector
#'
#' @param x a character vector
#'
#' @return a logical vector indicating if each value is missing
#' @export
is_missing <- function(x) {
  is.na(x) | x == ""
}

