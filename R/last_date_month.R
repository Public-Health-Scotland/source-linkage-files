#' Return the end date of the month of the given date
#'
#' @description Return the end date of the month of the given date
#'
#' @param x a date with a date format
#'
#' @return a vector of dates of the end date of the FY year
#' @export
#'
#' @examples
#' last_date_month(lubridate::as_date("2020-02-05"))
#'
#' @family date functions
last_date_month = function(x){
  return(lubridate::ceiling_date(x, "month") - lubridate::days(1))
}
