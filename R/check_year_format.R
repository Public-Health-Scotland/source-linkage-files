#' Check that the year is in the correct format
#'
#' @description Test to check that the year vector is in the correct format
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
#' year <- check_year_format("1920")
#'
#' @family year functions
check_year_format <- function(year, format = "fyyear") {
  if (any(is.na(year))) {
    cli::cli_abort("{.var year} must not be {.val NA}")
  }

  if (!is.character(year)) {
    cli::cli_inform(c("i" = "{.var year} will be converted to a {.class character}."))
    year <- as.character(year)
  }

  format <- match.arg(arg = format, choices = c("fyyear", "alternate"))

  first_part <- as.integer(substr(year, 1, 2))
  second_part <- as.integer(substr(year, 3, 4))

  if (format == "fyyear") {
    if (any(first_part + 1L != second_part)) {
      cli::cli_abort(c(
        "The {.var year} has been entered in the wrong format.",
        "Try again using the standard form, e.g. {.val 1718}",
        "Or use the function {.fun convert_year_to_fyyear}."
      ))
    }
  } else if (format == "alternate") {
    if (any(!(first_part %in% c(18:20)))) {
      cli::cli_abort(c(
        "The {.var year} has been entered in the wrong format.",
        "Try again using the alternate form, e.g. {.val 2017}",
        "Or use the function {.fun convert_fyyear_to_year}."
      ))
    } else if (any(first_part != 20 & first_part + 1L == second_part)) {
      possible_bad_values <- first_part != 20 & first_part + 1L == second_part
      count_bad_values <- sum(possible_bad_values)

      cli::cli_warn(c(
        "{cli::qty(count_bad_values)}{?A/Some} {.var year} value{?s} ha{?s/ve} likely been entered in the wrong format.",
        "i" = "{.val {year[possible_bad_values]}}",
        "You might want to check and try again using the alternate form, e.g. {.val 2017}",
        "Or use the function {.fun convert_fyyear_to_year}."
      ))
    }
  }

  return(year)
}
