#' Check there is data available for a given year
#' as some extracts are year dependent. E.g Homelessness
#' is only available from 2016/17 onwards.
#'
#' @param year Financial year
#' @param type name of extract
#'
#' @return A logical TRUE/FALSE
#' @export
#'
check_year_valid <- function(year, type = c(
                               "Acute",
                               "AE",
                               "AT",
                               "CH",
                               "Client",
                               "CMH",
                               "DD",
                               "Deaths",
                               "DN",
                               "GPOoH",
                               "HC",
                               "Homelessness",
                               "Maternity",
                               "MH",
                               "Outpatients",
                               "PIS",
                               "SDS"
                             )) {
  if (year <= "1415") {
    if (type %in% c("CMH", "DN", "Homelessness")) {
      return(FALSE)
    }
  } else if (year <= "1516") {
    if (type %in% c("CMH", "Homelessness")) {
      return(FALSE)
    }
  } else if (year >= "2122") {
    if (type %in% c("CMH", "DN")) {
      return(FALSE)
    }
  } else {
    return(TRUE)
  }
}
