#' Function for checking if variables have missing values or blank
#'
#' @param x Variable for checking missing values
#'
#' @return Check for missing (NA) or blank values.
#' @export
is_missing <- function(x) {
  is.na(x) | x == ""
}

