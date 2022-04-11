#' Check that the year is in the correct format
#'
#' @param year the year to check
#' @param format the format that year should be using. Default is "fyyear" for
#' example `1718`, the other format available is "alternate" e.g. `2017`
#'
#' @return The year if the check passes, it will be converted to a character if
#' not already.
#' @export
#'
#' @examples
#' year <- "1920"
#' year <- check_year_format(year)
check_year_format <- function(year, format = "fyyear") {
  if (!is.character(year)) {
    rlang::warn(message = c("i" = "`year` should be a character, it will be converted."))
    year <- as.character(year)
  }

  format <- match.arg(arg = format, choices = c("fyyear", "alternate"))

  first_part <- substr(year, 1, 2)
  second_part <- substr(year, 3, 4)

  if (format == "fyyear") {
    if (any(as.integer(first_part) + 1L != as.integer(second_part))) {
      rlang::abort(c(
        "The year has been entered in the wrong format.",
        "Try again using the standard form, e.g. `1718`",
        "Or use the function `convert_year_to_fyyear`."
      ))
    }
  } else if (format == "alternate") {
    if (any(as.integer(first_part) != 20)) {
      rlang::abort(c(
        "The year has been entered in the wrong format.",
        "Try again using the alternate form, e.g. `2017`",
        "Or use the function `convert_fyyear_to_year`."
      ))
    }
  }

  return(year)
}
