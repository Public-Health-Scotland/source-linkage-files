#' Is a date in the financial year
#'
#' @param date A date to be checked
#' @param year The financial year in the format '1718' as a character.
#'
#' @return logical
#' @export
#'
#' @examples
#' is_date_in_year(Sys.time(), "2223")
is_date_in_year <- function(date, year) {
  lubridate::`%within%`(date, fy_interval(year))
}
