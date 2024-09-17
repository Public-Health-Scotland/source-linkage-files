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
      "acute",
      "ae",
      "at",
      "ch",
      "client",
      "cmh",
      "cost_dna",
      "dd",
      "deaths",
      "dn",
      "gpooh",
      "hc",
      "homelessness",
      "hhg",
      "maternity",
      "mh",
      "nsu",
      "outpatients",
      "pis",
      "sds",
      "sparra"
    )) {
  if (year <= "1415" && type %in% c("dn", "sparra")) {
    return(FALSE)
  } else if (year <= "1516" && type %in% c("cmh", "homelessness", "dd")) {
    return(FALSE)
  } else if (year <= "1617" && type %in% c("ch", "hc", "sds", "at", "client", "cost_dna")) {
    return(FALSE)
  } else if (year <= "1718" && type %in% "hhg") {
    return(FALSE)
  } else if (year >= "2122" && type %in% c("cmh", "dn")) {
    return(FALSE)
  } else if (year >= "2324" && type %in% c("nsu", "hhg")) {
    return(FALSE)
  } else if (year >= "2425" && type %in% "sparra") {
    return(FALSE)
  } else if (year >= "2526" && type %in% c("ch", "hc", "sds", "at")) {
    return(FALSE)
  }

  return(TRUE)
}
