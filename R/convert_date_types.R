#' Convert a date type to the 'SLF numeric format'
#'
#' @description Convert a date to the 'SLF numeric format' - YYYYMMDD
#'
#' @param date a vector of dates
#'
#' @return a vector of numerics where the number is of the form YYYYMMDD
#' @export
#'
#' @examples
#' convert_date_to_numeric(as.Date("2021-03-31"))
#'
#' @family date functions
convert_date_to_numeric <- function(date) {
  as.integer(format(date, "%Y%m%d"))
}

#' Convert a date in 'SLF numeric format' to Date type
#'
#' @description Convert a numeric vector to a date - YYYY-MM-DD
#'
#' @param numeric_date a numeric vector containing dates in the form YYYYMMDD
#'
#' @return a Date vector
#' @export
#'
#' @examples
#' convert_numeric_to_date(c(20210101, 19993112))
#'
#' @family date functions
convert_numeric_to_date <- function(numeric_date) {
  as.Date(lubridate::fast_strptime(
    x = as.character(numeric_date),
    format = "%Y%m%d",
    tz = "UTC"
  ))
}
