#' Return the end date of the month of the given date
#'
#' @param date a date with a date format.
#'
#' @return a vector of dates, giving the last day of the month.
#'
#' @export
#'
#' @examples
#' last_date_month(Sys.Date())
#'
#' @family date functions
last_date_month <- function(date) {
  return(lubridate::ceiling_date(date, "month") - lubridate::days(1L))
}
