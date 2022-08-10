#' Check for NA or blank values in a character vector
#'
#' @description Checks within a vector if there are any missing (NA) or blank characters
#'
#' @param x a character vector
#'
#' @return a logical vector indicating if each value is missing
#' @export
#'
#' @examples
#' x <- c("string", " ", NA)
#' is_missing(x)
is_missing <- function(x) {
  if (typeof(x) != "character") {
    rlang::abort(
      message = glue::glue("You must supply a character vector, but {class(x)} was supplied.")
    )
  }

  return(is.na(x) | x == "")
}
