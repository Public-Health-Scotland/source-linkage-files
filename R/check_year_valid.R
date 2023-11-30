#' Check data exists for a year
#'
#' @description  Check there is data available for a given year
#' as some extracts are year dependent. E.g Homelessness
#' is only available from 2016/17 onwards.
#'
#' @param year Financial year
#' @param type name of extract
#'
#' @return A logical TRUE/FALSE
check_year_valid <- function(
    year,
    type = c(
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
      "SPARRA"
    )) {
  if (year <= "1415" && type %in% c("DN", "SPARRA")) {
    return(FALSE)
  } else if (year <= "1516" && type %in% c("CMH", "Homelessness")) {
    return(FALSE)
  } else if (year <= "1617" && type %in% c("CH", "HC", "SDS", "AT")) {
    return(FALSE)
  } else if (year <= "1718" && type %in% "HHG") {
    return(FALSE)
  } else if (year >= "2021" && type %in% c("CMH", "DN")) {
    return(FALSE)
  } else if (year >= "2324" && type %in% "NSU") {
    return(FALSE)
  } else if (year >= "2425" && type %in% c("SPARRA", "HHG")) {
    return(FALSE)
  } else if (year >= "2324" && type %in% c("CH", "HC", "SDS", "AT")) {
    return(FALSE)
  }

  return(TRUE)
}
