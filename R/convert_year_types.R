
#' Convert year types - Financial year form to the alternate form
#'
#' Converts year type from the financial year form '1718' to the year form '2017'.
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
  first_part <- substr(fyyear, 1, 2)
  second_part <- substr(fyyear, 3, 4)
  if (any(as.integer(first_part) + 1L != as.integer(second_part))) {
    stop("Year has been entered in the wrong format, try again using form `1718` or use function `convert_year_to_fyyear` to convert to the financial year form.")
  }
  year <- paste0("20", first_part)
  return(year)
}



#' Convert year types - Alternate year form to financial year form
#'
#' Convert a year type from alternate form '2017' to normal financial year form '1718'.
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
  if (any((substr(year, 1, 2) != "20"))) {
    stop("Year has been entered in the wrong format, try again using form `2017` or use function `convert_fyyear_to_year` to convert to alternate year form.")
  }
  fyyear <- paste0(substr(year, 3, 4), as.numeric(substr(year, 3, 4)) + 1)
  return(fyyear)
}
