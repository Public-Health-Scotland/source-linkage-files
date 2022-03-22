#' Check for NA or blank values in a character vector
#'
#' @param x a character vector
#'
#' @return a logical vector indicating if each value is missing
#' @export
is_missing <- function(x) {
  if (typeof(x) != "character") {
    rlang::abort(
      message = glue::glue("You must supply a character vector, but {class(x)} was supplied.")
    )
  }

  return(is.na(x) | x == "")
}
