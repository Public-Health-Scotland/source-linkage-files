#' Compute Age at Midpoint of Clients
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
#' compute_age(ca)
compute_age <- function(data, year, dob) {
  data <- data %>%
    # age
    mutate(age = lubridate::as.period(lubridate::interval(start = dob, end = midpoint_fy(fyyear)))$year)
}
