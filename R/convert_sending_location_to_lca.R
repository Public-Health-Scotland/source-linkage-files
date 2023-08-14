#' Convert Social Care Sending Location Codes into LCA Codes
#'
#' @description Convert Social Care Sending Location Codes into the
#' Local Council Authority Codes.
#'
#' @param sending_location vector of sending location codes
#'
#' @return a vector of local council authority codes
#' @export
#'
#' @examples
#' sending_location <- c("100", "120")
#' convert_sending_location_to_lca(sending_location)
#'
#' @family code functions
#'
#' @seealso convert_ca_to_lca
convert_sending_location_to_lca <- function(sending_location) {
  lca <- dplyr::case_match(
    sending_location,
    "100" ~ "01", # Aberdeen City
    "110" ~ "02", # Aberdeenshire
    "120" ~ "03", # Angus
    "130" ~ "04", # Argyll and Bute
    "355" ~ "05", # Scottish Borders
    "150" ~ "06", # Clackmannanshire
    "395" ~ "07", # West Dumbartonshire
    "170" ~ "08", # Dumfries and Galloway
    "180" ~ "09", # Dundee City
    "190" ~ "10", # East Ayrshire
    "200" ~ "11", # East Dunbartonshire
    "210" ~ "12", # East Lothian
    "220" ~ "13", # East Renfrewshire
    "230" ~ "14", # City of Edinburgh
    "240" ~ "15", # Falkirk
    "250" ~ "16", # Fife
    "260" ~ "17", # Glasgow City
    "270" ~ "18", # Highland
    "280" ~ "19", # Inverclyde
    "290" ~ "20", # Midlothian
    "300" ~ "21", # Moray
    "310" ~ "22", # North Ayrshire
    "320" ~ "23", # North Lanarkshire
    "330" ~ "24", # Orkney Islands
    "340" ~ "25", # Perth and Kinross
    "350" ~ "26", # Renfrewshire
    "360" ~ "27", # Shetland Islands
    "370" ~ "28", # South Ayrshire
    "380" ~ "29", # South Lanarkshire
    "390" ~ "30", # Stirling
    "400" ~ "31", # West Lothian
    "235" ~ "32" # Na_h_Eileanan_Siar
  )
  return(lca)
}
