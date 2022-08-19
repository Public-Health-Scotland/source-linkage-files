#' Return the start date of FY year
#'
#' @description Get the start date of the specified financial year
#'
#' @param year a character vector of years
#' @param format the format of the year vector, default is financial year
#'
#' @return a vector of the start dates of the FY year
#' @export
#'
#' @examples
#' start_fy("1718")
#'
#' @family date functions
start_fy <- function(year, format = c("fyyear", "alternate")) {
  if (missing(format)) {
    format <- "fyyear"
  }

  format <- match.arg(format)

  if (format == "fyyear") {
    start_fy <- as.Date(paste0(convert_fyyear_to_year(year), "-04-01"))
  } else if (format == "alternate") {
    start_fy <- as.Date(paste0(year, "-04-01"))
  }

  return(start_fy)
}


#' Return the end date of FY years
#'
#' @description Get the end date of the specified financial year
#'
#' @inheritParams start_fy
#'
#' @return a vector of dates of the end date of the FY year
#' @export
#'
#' @examples
#' end_fy("1718")
#'
#' @family date functions
end_fy <- function(year, format = c("fyyear", "alternate")) {
  if (missing(format)) {
    format <- "fyyear"
  }

  format <- match.arg(format)

  if (format == "fyyear") {
    end_fy <- as.Date(paste0(as.numeric(convert_fyyear_to_year(year)) + 1, "-03-31"))
  } else if (format == "alternate") {
    end_fy <- as.Date(paste0(as.numeric(year) + 1, "-03-31"))
  }

  return(end_fy)
}


#' Return the date of the midpoint of the FY year
#'
#' @description Get the date of the midpoint of the specified financial year
#'
#' @inheritParams start_fy
#'
#' @return a vector of dates of the mid date of the FY year
#'
#' @export
#'
#' @examples
#' midpoint_fy("1718")
#'
#' @family date functions
midpoint_fy <- function(year, format = c("fyyear", "alternate")) {
  if (missing(format)) {
    format <- "fyyear"
  }

  format <- match.arg(format)

  if (format == "fyyear") {
    midpoint_fy <- as.Date(paste0(convert_fyyear_to_year(year), "-09-30"))
  } else if (format == "alternate") {
    midpoint_fy <- as.Date(paste0(year, "-09-30"))
  }

  return(midpoint_fy)
}


#' Financial Year interval
#'
#' @description Get the interval between the start date and end date of the
#' specified financial year
#'
#' @inheritParams start_fy
#'
#' @return An [interval][lubridate::interval()]
#' @export
#'
#' @examples
#' fy_interval("1920")
#'
#' @family date functions
fy_interval <- function(year) {
  # year must be the correct type
  check_year_format(year, format = "fyyear")

  lubridate::interval(start = start_fy(year), end = end_fy(year))
}
