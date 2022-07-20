#' Check if a date, or interval is in the financial year
#'
#' @description Test to check if a date, or intervals is within a given
#' financial year. If given just one date it will check to see if it is in the
#' given financial year. When supplied with two dates it will check to see if
#' any part of that date range falls in the given financial year.
#'
#' @param date The main / start date to check
#' @param fyyear The financial year in the format '1718' as a character
#' @param date_end (optional) The end date
#'
#' @return a logical T/F
#'
#' @export
#'
#' @examples
#' is_date_in_fyyear(Sys.time(), "2223")
#' is_date_in_fyyear(
#'   fyyear = "2122",
#'   date = as.Date("2020-01-01"),
#'   date_end = as.Date("2023-01-01"),
#'   fyyear = "2122"
#' )
#'
#' @family date functions
is_date_in_fyyear <- function(date, fyyear, date_end = NULL) {
  if (is.null(date_end)) {
    lubridate::`%within%`(date, fy_interval(fyyear))
  } else {
    if (date > date_end) {
      cli::cli_abort("The start date cannot come after the end date.")
    }

    date_interval <- lubridate::interval(date, date_end)

    lubridate::int_overlaps(date_interval, fy_interval(fyyear))
  }
}
