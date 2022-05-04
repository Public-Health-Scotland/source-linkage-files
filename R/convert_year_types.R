#' Convert year types - Financial year form to the alternate form
#'
#' Converts year type from the financial year form
#' '1718' to the year form '2017'.
#'
#' @param fyyear vector of financial years in the form '1718'
#'
#' @return a vector of years in the alternate form '2017'
#' @export
#'
#' @examples
#' fyyears <- c("1718", "1819")
#' convert_fyyear_to_year(fyyears)
convert_fyyear_to_year <- function(fyyear) {
  fyyear <- check_year_format(year = fyyear, format = "fyyear")

  year <- paste0("20", substr(fyyear, 1, 2))

  return(year)
}

#' Convert year types - Alternate year form to financial year form
#'
#' Convert a year type from alternate form '2017' to normal
#' financial year form '1718'.
#'
#' @param year vector of years in the form '2017'
#'
#' @return a vector of years in the normal financial year form '1718'
#' @export
#'
#' @examples
#' years <- c("2017", "2018")
#' convert_year_to_fyyear(years)
convert_year_to_fyyear <- function(year) {
  year <- check_year_format(year = year, format = "alternate")

  fyyear <- paste0(substr(year, 3, 4), as.integer(substr(year, 3, 4)) + 1L)

  return(fyyear)
}
