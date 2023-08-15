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
    100L ~ "01", # Aberdeen City
    110L ~ "02", # Aberdeenshire
    120L ~ "03", # Angus
    130L ~ "04", # Argyll and Bute
    355L ~ "05", # Scottish Borders
    150L ~ "06", # Clackmannanshire
    395L ~ "07", # West Dunbartonshire
    170L ~ "08", # Dumfries and Galloway
    180L ~ "09", # Dundee City
    190L ~ "10", # East Ayrshire
    200L ~ "11", # East Dunbartonshire
    210L ~ "12", # East Lothian
    220L ~ "13", # East Renfrewshire
    230L ~ "14", # City of Edinburgh
    240L ~ "15", # Falkirk
    250L ~ "16", # Fife
    260L ~ "17", # Glasgow City
    270L ~ "18", # Highland
    280L ~ "19", # Inverclyde
    290L ~ "20", # Midlothian
    300L ~ "21", # Moray
    310L ~ "22", # North Ayrshire
    320L ~ "23", # North Lanarkshire
    330L ~ "24", # Orkney Islands
    340L ~ "25", # Perth and Kinross
    350L ~ "26", # Renfrewshire
    360L ~ "27", # Shetland Islands
    370L ~ "28", # South Ayrshire
    380L ~ "29", # South Lanarkshire
    390L ~ "30", # Stirling
    400L ~ "31", # West Lothian
    235L ~ "32", # Na_h_Eileanan_Siar
    .default = NA_character_
  )

  return(lca)
}
