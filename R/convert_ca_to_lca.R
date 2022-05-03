#' Convert Council Areas into Local Council Authority Codes
#'
#' @param ca_var vector of council area codes or names
#'
#' @return a vector of local council codes
#' @export
#'
#' @examples
#' ca <- c("S12000033", "S12000034")
#' convert_ca_to_lca(ca)
convert_ca_to_lca <- function(ca_var) {
  lca <- dplyr::case_when(
    ca_var == "S12000033" | ca_var == "Aberdeen City" ~ "01", # Aberdeen City
    ca_var == "S12000034" | ca_var == "Aberdeenshire" ~ "02", # Aberdeenshire
    ca_var == "S12000041" | ca_var == "Angus" ~ "03", # Angus
    ca_var == "S12000035" | ca_var == "Argyll & Bute" ~ "04", # Argyll & Bute
    ca_var == "S12000026" | ca_var == "Scottish Borders" ~ "05", # Scottish Borders
    ca_var == "S12000005" | ca_var == "Clackmannanshire" ~ "06", # Clackmannanshire
    ca_var == "S12000039" | ca_var == "West Dunbartonshire" ~ "07", # West Dun
    ca_var == "S12000006" | ca_var == "Dumfries and Galloway" ~ "08", # Dumfries and Galloway
    ca_var == "S12000042" | ca_var == "Dundee City" ~ "09", # Dundee City
    ca_var == "S12000008" | ca_var == "East Ayrshire" ~ "10", # East Ayrshire
    ca_var == "S12000045" | ca_var == "East Dunbartonshire" ~ "11", # East Dun
    ca_var == "S12000010" | ca_var == "East Lothian" ~ "12", # East Lothian
    ca_var == "S12000011" | ca_var == "East Renfrewshire" ~ "13", # East Ren
    ca_var == "S12000036" | ca_var == "City of Edinburgh" ~ "14", # City of Edinburgh
    ca_var == "S12000014" | ca_var == "Falkirk" ~ "15", # Falkirk
    ca_var %in% c("S12000015", "S12000047") | ca_var == "Fife" ~ "16", # Fife
    ca_var %in% c("S12000046", "S12000049") | ca_var == "Glasgow City" ~ "17", # Glasgow City
    ca_var == "S12000017" | ca_var == "Highland" ~ "18", # Highland
    ca_var == "S12000018" | ca_var == "Inverclyde" ~ "19", # Inverclyde
    ca_var == "S12000019" | ca_var == "Midlothian" ~ "20", # Midlothian
    ca_var == "S12000020" | ca_var == "Moray" ~ "21", # Moray
    ca_var == "S12000021" | ca_var == "North Ayrshire" ~ "22", # North Ayrshire
    ca_var %in% c("S12000044", "S12000050") | ca_var == "North Lanarkshire" ~ "23", # North Lan
    ca_var == "S12000023" | ca_var == "Orkney" ~ "24", # Orkney
    ca_var %in% c("S12000024", "S12000048") | ca_var == "Perth and Kinross" ~ "25", # P and K
    ca_var == "S12000038" | ca_var == "Renfrewshire" ~ "26", # Renfrewshire
    ca_var == "S12000027" | ca_var == "Shetland Islands" ~ "27", # Shetland
    ca_var == "S12000028" | ca_var == "South Ayrshire" ~ "28", # South Ayrshire
    ca_var == "S12000029" | ca_var == "South Lanarkshire" ~ "29", # South Lan
    ca_var == "S12000030" | ca_var == "Stirling" ~ "30", # Stirling
    ca_var == "S12000040" | ca_var == "West Lothian" ~ "31", # West Lothian
    ca_var == "S12000013" | ca_var == "Na h-Eileanan Siar" | ca_var == "Comhairle nan Eilean Siar" ~ "32" # Na h-Eileanan Siar
  )
  return(lca)
}
