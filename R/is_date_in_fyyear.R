#' Check if a date, or interval is in the financial year
#'
#' @description Test to check if a date, or intervals is within a given
#' financial year. If given just one date it will check to see if it is in the
#' given financial year. When supplied with two dates it will check to see if
#' any part of that date range falls in the given financial year.
#'
#' @param fyyear The financial year in the format '1718' as a character
#' @param date The main/start date to check
#' @param date_end (optional) The end date
#'
#' @return a logical T/F or `NA` if either of the dates are `NA`
#'
#' @export
#'
#' @examples
#' is_date_in_fyyear("2223", Sys.time())
#' is_date_in_fyyear(
#'   fyyear = "2122",
#'   date = as.Date("2020-01-01"),
#'   date_end = as.Date("2023-01-01")
#' )
#'
#' @family date functions
is_date_in_fyyear <- function(fyyear, date, date_end = NULL) {
  if (is.null(date_end)) {
    return(lubridate::`%within%`(date, fy_interval(fyyear)))
  } else {
    date_interval <- lubridate::interval(date, date_end)

    return(lubridate::int_overlaps(date_interval, fy_interval(fyyear)))
  }
}
