#' Convert Council Areas into Local Council Authority Codes
#'
#' @description Convert Council Area code into the Local Council Authority code
#'
#' @param ca_var vector of council area codes or names
#'
#' @return a vector of local council authority codes
#' @export
#'
#' @examples
#' ca <- c("S12000033", "S12000034")
#' convert_ca_to_lca(ca)
#'
#' @family code functions
#' @seealso convert_sending_location_to_lca
convert_ca_to_lca <- function(ca_var) {
  lca <- dplyr::case_when(
    ca_var == "S12000033" | ca_var == "Aberdeen City" ~ "01",
    ca_var == "S12000034" | ca_var == "Aberdeenshire" ~ "02",
    ca_var == "S12000041" | ca_var == "Angus" ~ "03",
    ca_var == "S12000035" | ca_var == "Argyll & Bute" ~ "04",
    ca_var == "S12000026" | ca_var == "Scottish Borders" ~ "05",
    ca_var == "S12000005" | ca_var == "Clackmannanshire" ~ "06",
    ca_var == "S12000039" | ca_var == "West Dunbartonshire" ~ "07",
    ca_var == "S12000006" | ca_var == "Dumfries and Galloway" ~ "08",
    ca_var == "S12000042" | ca_var == "Dundee City" ~ "09",
    ca_var == "S12000008" | ca_var == "East Ayrshire" ~ "10",
    ca_var == "S12000045" | ca_var == "East Dunbartonshire" ~ "11",
    ca_var == "S12000010" | ca_var == "East Lothian" ~ "12",
    ca_var == "S12000011" | ca_var == "East Renfrewshire" ~ "13",
    ca_var == "S12000036" | ca_var == "City of Edinburgh" ~ "14",
    ca_var == "S12000014" | ca_var == "Falkirk" ~ "15",
    ca_var %in% c("S12000015", "S12000047") | ca_var == "Fife" ~ "16",
    ca_var %in% c("S12000046", "S12000049") | ca_var == "Glasgow City" ~ "17",
    ca_var == "S12000017" | ca_var == "Highland" ~ "18",
    ca_var == "S12000018" | ca_var == "Inverclyde" ~ "19",
    ca_var == "S12000019" | ca_var == "Midlothian" ~ "20",
    ca_var == "S12000020" | ca_var == "Moray" ~ "21",
    ca_var == "S12000021" | ca_var == "North Ayrshire" ~ "22",
    ca_var %in% c("S12000044", "S12000050") | ca_var == "North Lanarkshire" ~ "23",
    ca_var == "S12000023" | ca_var == "Orkney" ~ "24",
    ca_var %in% c("S12000024", "S12000048") | ca_var == "Perth and Kinross" ~ "25",
    ca_var == "S12000038" | ca_var == "Renfrewshire" ~ "26",
    ca_var == "S12000027" | ca_var == "Shetland Islands" ~ "27",
    ca_var == "S12000028" | ca_var == "South Ayrshire" ~ "28",
    ca_var == "S12000029" | ca_var == "South Lanarkshire" ~ "29",
    ca_var == "S12000030" | ca_var == "Stirling" ~ "30",
    ca_var == "S12000040" | ca_var == "West Lothian" ~ "31",
    ca_var == "S12000013" | ca_var == "Na h-Eileanan Siar" | ca_var == "Comhairle nan Eilean Siar" ~ "32"
  )
  return(lca)
}
