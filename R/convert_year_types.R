#' Convert a year type from normal '1718' to alternate '2017'
#'
#' @param fyyear vector of financial year in the form '1718'
#'
#' @return a vector of years in the alternate form '2017'
#' @export
#'
#' @examples
#' convert_fyyear_to_year(c("2017", "2018"))
convert_fyyear_to_year <- function(fyyear) {
  year <- paste0("20", substr(fyyear, 1, 2))
  return (year)
}


#' Convert a year type from alternate '2017' to normal '1718'
#'
#' @param year vector of years in the form '2017'
#'
#' @return a vector of years in the normal form '1718'
#' @export
#'
#' @examples
#' convert_year_to_fyyear(c("1718", "1819"))
convert_year_to_fyyear <- function(year) {
  fyyear <- paste0(substr(year, 3, 4), as.numeric(substr(year, 3, 4)) + 1)
  return (as.numeric(fyyear))
}
