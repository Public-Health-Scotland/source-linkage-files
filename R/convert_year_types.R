#' Convert year types - Financial year form to the alternate form
#'
#' @description Convert a year vector from financial year '1718' to the alternate format '2017'
#'
#' @param fyyear vector of financial years in the form '1718'
#'
#' @return a vector of years in the alternate form '2017'
#' @export
#'
#' @examples
#' fyyears <- c("1718", "1819")
#' convert_fyyear_to_year(fyyears)
#'
#' @family year functions
convert_fyyear_to_year <- function(fyyear) {
  fyyear <- check_year_format(year = fyyear, format = "fyyear")

  year <- paste0("20", substr(fyyear, 1, 2))

  return(year)
}

#' Convert year types - Alternate year form to financial year form
#'
#' @description Convert a year vector from the alternate format '2017' to financial year format '2017'
#'
#' @param year vector of years in the form '2017'
#'
#' @return a vector of years in the normal financial year form '1718'
#' @export
#'
#' @examples
#' years <- c("2017", "2018")
#' convert_year_to_fyyear(years)
#'
#' @family year functions
convert_year_to_fyyear <- function(year) {
  year <- check_year_format(year = year, format = "alternate")

  first_part <- substr(year, 1, 2)
  second_part <- substr(year, 3, 4)

  fyyear <-
    dplyr::if_else(
      substr(second_part, 1, 1) != "0",
      paste0(second_part, as.integer(second_part) + 1L),
      paste0(second_part, "0", as.integer(second_part) + 1L)
    )

  if (length(year) > 1 && any(first_part != "20")) {
    non_21c <- which(first_part != "20")

    cli::cli_warn(c(
      "i" = "{cli::qty(length(non_21c))}{?A/Some} value{?s} w{?as/ere} not in the 21st century i.e. not {.val 20xx}",
      "This may have produced unexpected results, specifically:",
      "*" = "{.val {year[non_21c]}} -> {.val {fyyear[non_21c]}}"
    ))
  }

  return(fyyear)
}
