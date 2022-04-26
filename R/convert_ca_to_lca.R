#' Convert Council Areas into Local Council Authority Codes
#'
#' @param ca vector of council area codes or names
#'
#' @return a vector of local council codes
#' @export
#'
#' @examples
#' ca <- c("S12000033", "S12000034")
#' ca_to_lca(ca)
ca_to_lca <- function(ca) {
  lca <- dplyr::case_when(
    ca == "S12000033" | ca == "Aberdeen City" ~ "01", # Aberdeen City
    ca == "S12000034" | ca == "Aberdeenshire" ~ "02", # Aberdeenshire
    ca == "S12000041" | ca == "Angus" ~ "03", # Angus
    ca == "S12000035" | ca == "Argyll and Bute" ~ "04", # Argyll and Bute
    ca == "S12000026" | ca == "Scottish Borders" ~ "05", # Scottish Borders
    ca == "S12000005" | ca == "Clackmannanshire" ~ "06", # Clackmannanshire
    ca == "S12000039" | ca == "West Dunbartonshire" ~ "07", # West Dun
    ca == "S12000006" | ca == "Dumfries and Galloway" ~ "08", # Dumfries and Galloway
    ca == "S12000042" | ca == "Dundee City" ~ "09", # Dundee City
    ca == "S12000008" | ca == "East Ayrshire" ~ "10", # East Ayrshire
    ca == "S12000045" | ca == "East Dunbartonshire" ~ "11", # East Dun
    ca == "S12000010" | ca == "East Lothian" ~ "12", # East Lothian
    ca == "S12000011" | ca == "East Renfrewshire" ~ "13", # East Ren
    ca == "S12000036" | ca == "City of Edinburgh" ~ "14", # City of Edinburgh
    ca == "S12000014" | ca == "Falkirk" ~ "15", # Falkirk
    ca %in% c("S12000015", "S12000047") | ca == "Fife" ~ "16", # Fife
    ca %in% c("S12000046", "S12000049") | ca == "Glasgow City" ~ "17", # Glasgow City
    ca == "S12000017" | ca == "Highland" ~ "18", # Highland
    ca == "S12000018" | ca == "Inverclyde" ~ "19", # Inverclyde
    ca == "S12000019" | ca == "Midlothian" ~ "20", # Midlothian
    ca == "S12000020" | ca == "Moray" ~ "21", # Moray
    ca == "S12000021" | ca == "North Ayrshire" ~ "22", # North Ayrshire
    ca %in% c("S12000044", "S12000050") | ca == "North Lanarkshire" ~ "23", # North Lan
    ca == "S12000023" | ca == "Orkney" ~ "24", # Orkney
    ca %in% c("S12000024", "S12000048") | ca == "Perth and Kinross" ~ "25", # P and K
    ca == "S12000038" | ca == "Renfrewshire" ~ "26", # Renfrewshire
    ca == "S12000027" | ca == "Shetland Islands" ~ "27", # Shetland
    ca == "S12000028" | ca == "South Ayrshire" ~ "28", # South Ayrshire
    ca == "S12000029" | ca == "South Lanarkshire" ~ "29", # South Lan
    ca == "S12000030" | ca == "Stirling" ~ "30", # Stirling
    ca == "S12000040" | ca == "West Lothian" ~ "31", # West Lothian
    ca == "S12000013" | ca == "Na h-Eileanan Siar" | ca == "Comhairle nan Eilean Siar" ~ "32" # Na h-Eileanan Siar
  )
  return(lca)
}
