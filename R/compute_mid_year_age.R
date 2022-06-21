#' Compute Age at Midpoint of Year
#'
#' @param fyyear financial year
#' @param dob date of birth
#'
#' @return a vector of ages at the financial year midpoint
#' @export
#'
#' @examples
#' dob <- as.Date(c("01-01-1990", "10-05-1960"))
#' fyyear <- "1920"
#' compute_mid_year_age(fyyear, dob)
compute_mid_year_age <- function(fyyear, dob) {

 age_intervals <- lubridate::interval(start = dob, end = midpoint_fy(fyyear))

 ages <- lubridate::as.period(age_intervals$year)
 
 return(ages)
}
