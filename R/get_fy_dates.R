#' Return the start date of FY year
#'
#' @param year a vector of years
#'
#' @return a vector of dates of the start date of the FY year
#' @export
#'
#' @examples
#' startFY("1718")
start_fy <- function(year) {
  as.Date(paste0(as.numeric(convert_fyyear_to_year(year)), "-04-01"))
}


#' Return the end date of FY years
#'
#' @param year a vector of years
#'
#' @return a vector of dates of the end date of the FY year
#' @export
#'
#' @examples
#' endFY("1718")
end_fy <- function(year) {
  as.Date(paste0((as.numeric(convert_fyyear_to_year(year)) + 1), "-03-31"))
}


#' Return the mid date of FY year
#'
#' @param year a vector of years
#'
#' @return a vector of dates of the mid date of the FY year
#' @export
#'
#' @examples
#' midpointFY("1718")
midpoint_fy <- function(year) {
  as.Date(paste0(as.numeric(convert_fyyear_to_year(year)), "-09-30"))
}

