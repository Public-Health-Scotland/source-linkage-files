#' Return the start date of FY year
#'
#' @param year a vector of years
#'
#' @return a vector of dates of the start date of the FY year
#' @export
#'
#' @examples
#' start_fy("1718")
start_fy <- function(year, format = c("fyyear", "alternate")) {

  if (missing(format)) {format <- "fyyear"}

  format <- match.arg(format)

  if (format == "fyyear") {
    start_fy = as.Date(paste0(convert_fyyear_to_year(year), "-04-01"))
  } else if (format == "alternate") {
    start_fy = as.Date(paste0(year, "-04-01"))
  }

  return(start_fy)
}


#' Return the end date of FY years
#'
#' @param year a vector of years
#'
#' @return a vector of dates of the end date of the FY year
#' @export
#'
#' @examples
#' end_fy("1718")
end_fy <- function(year, format = c("fyyear", "alternate")) {

  if (missing(format)) {format <- "fyyear"}

  format <- match.arg(format)

  if (format == "fyyear") {
    end_fy = as.Date(paste0(as.numeric(convert_fyyear_to_year(year)) + 1, "-03-31"))
  } else if (format == "alternate") {
    end_fy = as.Date(paste0(as.numeric(year) + 1, "-03-31"))
  }

  return(end_fy)
}


#' Return the mid date of FY year
#'
#' @param year a vector of years
#'
#' @return a vector of dates of the mid date of the FY year
#' @export
#'
#' @examples
#' midpoint_fy("1718")
midpoint_fy <- function(year, format = c("fyyear", "alternate")) {

  if (missing(format)) {format <- "fyyear"}

  format <- match.arg(format)

  if (format == "fyyear") {
    midpoint_fy = as.Date(paste0(convert_fyyear_to_year(year), "-09-30"))
  } else if (format == "alternate") {
    midpoint_fy = as.Date(paste0(year, "-09-30"))
  }

  return(midpoint_fy)
}
