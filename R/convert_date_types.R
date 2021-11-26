#' Convert a date type to the 'SLF numeric format'
#'
#' @param date a vector of dates
#'
#' @return a vector of numerics where the number is of the form YYYYMMDD
#' @export
#'
#' @examples
#' date_to_numeric(as.Date("2021-03-31"))
date_to_numeric <- function(date) {
  lubridate::year(date) * 10000 +
    lubridate::month(date) * 100 +
    lubridate::day(date)
}

#' Convert a date in 'SLF numeric format' to Date type
#'
#' @param numeric_date a numeric vector containing dates in the form YYYYMMDD
#'
#' @return a Date vector
#' @export
#'
#' @examples
#' numeric_to_date(c(20210101, 19993112))
numeric_to_date <- function(numeric_date) {
  as.Date(strptime(as.character(numeric_date), "%Y%m%d", tz = "UTC"))
}
