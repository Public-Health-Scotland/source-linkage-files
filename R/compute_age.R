#' Compute Age of Clients at Midpoint of Year
#'
#' @param data data to assign age to
#' @param fyyear financial year
#' @param dob date of birth of the client
#'
#' @return a vector of age at midpoint
#' @export
#'
#' @examples
#' dob <- c("01-01-1990", "10-05-1960")
#' fyyear <- "1920"
#' compute_age(fyyear, dob)
compute_age <- function(data, fyyear, dob) {
  data <- data %>%
    # age
    dplyr::mutate(age = lubridate::as.period(lubridate::interval(start = dob, end = midpoint_fy(fyyear)))$year)
}
