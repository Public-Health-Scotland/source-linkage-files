#' Return the start date of FY year
#'
#' @param year a vector of year
#'
#' @return a vector of dates of the start date of the FY year
#' @export
#'
#' @examples
#' startFY("1718")
startFY <- function(FY) {
  as.Date(paste0(as.numeric(convert_fyyear_to_year(FY)), "-04-01"))
}


#' Return the end date of FY year
#'
#' @param year a vector of year
#'
#' @return a vector of dates of the end date of the FY year
#' @export
#'
#' @examples
#' endFY("1718")
endFY <- function(FY) {
  as.Date(paste0((as.numeric(convert_fyyear_to_year(FY)) + 1), "-03-31"))
}


#' Return the mid date of FY year
#'
#' @param year a vector of year
#'
#' @return a vector of dates of the mid date of the FY year
#' @export
#'
#' @examples
#' midpointFY("1718")
midpointFY <- function(FY) {
  #as.Date(startFY(FY) + floor((endFY(FY)-startFY(FY))/2))
  as.Date(paste0(as.numeric(convert_fyyear_to_year(FY)), "-09-30"))
}

