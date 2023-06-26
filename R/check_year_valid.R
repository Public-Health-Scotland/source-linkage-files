#' Check there is data available for a given year
#' as some extracts are year dependent. E.g Homelessness
#' is only available from 2016/17 onwards.
#'
#' @param year Financial year
#' @param type name of extract
#'
#' @return A logical TRUE/FALSE
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
                               "HHG",
                               "Maternity",
                               "MH",
                               "NSU",
                               "Outpatients",
                               "PIS",
                               "SDS",
                               "Sparra"
                             )) {
  if (year >= "2223" & type == "NSU") {
    return(FALSE)
  }

  if (year >= "2223" & type == "Sparra") {
    return(FALSE)
  }

  if (year <= "1718" & type == "HHG"){
    return(FALSE)
  }

  if (year <= "1415") {
    if (type %in% c("CMH", "DN", "Homelessness", "CH", "HC", "SDS", "AT")) {
      return(FALSE)
    }
  } else if (year <= "1516") {
    if (type %in% c("CMH", "Homelessness", "CH", "HC", "SDS", "AT")) {
      return(FALSE)
    }
  } else if (year <= "1617") {
    if (type %in% c("CH", "HC", "SDS", "AT")) {
      return(FALSE)
    }
  } else if (year >= "2122") {
    if (type %in% c("CMH", "DN")) {
      return(FALSE)
    }
  }
  return(TRUE)
}
