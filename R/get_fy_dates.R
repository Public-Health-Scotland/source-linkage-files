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
    start_fy <- lubridate::make_date(convert_fyyear_to_year(year), 4, 1)
  } else if (format == "alternate") {
    start_fy <- lubridate::make_date(year, 4, 1)
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

  year <- as.numeric(paste0("20", substr(year, 3, 4)))

  format <- match.arg(format)

  if (format == "fyyear") {
    end_fy <- lubridate::make_date(year, 3, 31)
  } else if (format == "alternate") {
    end_fy <- lubridate::make_date(year + 1L, 3, 31)
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

  check_year_format(year, format = "fyyear")

  if (format == "fyyear") {
    midpoint_fy <- lubridate::make_date(convert_fyyear_to_year(year), 9, 30)
  } else if (format == "alternate") {
    midpoint_fy <- lubridate::make_date(year, 9, 30)
  }

  return(midpoint_fy)
}

#' Return the next financial year
#'
#' @inheritParams start_fy
#'
#' @return A character of the date in the requested format
#' @export
#'
#' @examples
#' next_fy("1718")
#'
#' @family date functions
next_fy <- function(year, format = c("fyyear", "alternate")) {
  if (missing(format)) {
    format <- "fyyear"
  }

  format <- match.arg(format)

  check_year_format(year, format = "fyyear")

  fy <- as.integer(substr(year, 1, 2))

  next_fy <- paste0(fy + 1L, fy + 2L)

  if (format == "fyyear") {
    return(next_fy)
  } else if (format == "alternate") {
    return(convert_fyyear_to_year(next_fy))
  }
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
