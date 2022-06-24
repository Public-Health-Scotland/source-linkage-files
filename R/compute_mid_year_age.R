#' Compute Age at Midpoint of Year
#'
#' @description Compute the age of a client at the midpoint of the year - 30-09-YYYY
#'
#' @param fyyear current financial year
#' @param dob date of birth of the clients
#'
#' @return a vector of ages at the financial year midpoint
#' @export
#'
#' @examples
#' dob <- as.Date(c("01-01-1990", "31-10-1997"), format = "%d-%m-%Y")
#' fyyear <- "1920"
#' compute_mid_year_age(fyyear, dob)
#'
#' @family date functions
#'
#' @seealso midpoint_fy
compute_mid_year_age <- function(fyyear, dob) {
  age_intervals <- lubridate::interval(start = dob, end = as.Date(midpoint_fy(fyyear)))

  ages <- lubridate::as.period(age_intervals)$year

  return(ages)
}
