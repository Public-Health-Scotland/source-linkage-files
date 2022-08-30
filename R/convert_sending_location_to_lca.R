#' Convert Social Care Sending Location Codes into LCA Codes
#'
#' @description Convert Social Care Sending Location Codes into the Local Council Authority Codes
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
  lca <- dplyr::case_when(
    sending_location == "100" ~ "01", # Aberdeen City
    sending_location == "110" ~ "02", # Aberdeenshire
    sending_location == "120" ~ "03", # Angus
    sending_location == "130" ~ "04", # Argyll and Bute
    sending_location == "355" ~ "05", # Scottish Borders
    sending_location == "150" ~ "06", # Clackmannanshire
    sending_location == "395" ~ "07", # West Dumbartonshire
    sending_location == "170" ~ "08", # Dumfries and Galloway
    sending_location == "180" ~ "09", # Dundee City
    sending_location == "190" ~ "10", # East Ayrshire
    sending_location == "200" ~ "11", # East Dunbartonshire
    sending_location == "210" ~ "12", # East Lothian
    sending_location == "220" ~ "13", # East Renfrewshire
    sending_location == "230" ~ "14", # City of Edinburgh
    sending_location == "240" ~ "15", # Falkirk
    sending_location == "250" ~ "16", # Fife
    sending_location == "260" ~ "17", # Glasgow City
    sending_location == "270" ~ "18", # Highland
    sending_location == "280" ~ "19", # Inverclyde
    sending_location == "290" ~ "20", # Midlothian
    sending_location == "300" ~ "21", # Moray
    sending_location == "310" ~ "22", # North Ayrshire
    sending_location == "320" ~ "23", # North Lanarkshire
    sending_location == "330" ~ "24", # Orkney Islands
    sending_location == "340" ~ "25", # Perth and Kinross
    sending_location == "350" ~ "26", # Renfrewshire
    sending_location == "360" ~ "27", # Shetland Islands
    sending_location == "370" ~ "28", # South Ayrshire
    sending_location == "380" ~ "29", # South Lanarkshire
    sending_location == "390" ~ "30", # Stirling
    sending_location == "400" ~ "31", # West Lothian
    sending_location == "235" ~ "32" # Na_h_Eileanan_Siar
  )
  return(lca)
}
