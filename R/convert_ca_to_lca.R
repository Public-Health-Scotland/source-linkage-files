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
#' @seealso convert_sc_sending_location_to_lca
convert_ca_to_lca <- function(ca_var) {
  lca <- dplyr::case_match(
    ca_var,
    c("S12000033", "Aberdeen City") ~ "01",
    c("S12000034", "Aberdeenshire") ~ "02",
    c("S12000041", "Angus") ~ "03",
    c("S12000035", "Argyll & Bute") ~ "04",
    c("S12000026", "Scottish Borders") ~ "05",
    c("S12000005", "Clackmannanshire") ~ "06",
    c("S12000039", "West Dunbartonshire") ~ "07",
    c("S12000006", "Dumfries and Galloway") ~ "08",
    c("S12000042", "Dundee City") ~ "09",
    c("S12000008", "East Ayrshire") ~ "10",
    c("S12000045", "East Dunbartonshire") ~ "11",
    c("S12000010", "East Lothian") ~ "12",
    c("S12000011", "East Renfrewshire") ~ "13",
    c("S12000036", "City of Edinburgh") ~ "14",
    c("S12000014", "Falkirk") ~ "15",
    c("S12000015", "S12000047", "Fife") ~ "16",
    c("S12000046", "S12000049", "Glasgow City") ~ "17",
    c("S12000017", "Highland") ~ "18",
    c("S12000018", "Inverclyde") ~ "19",
    c("S12000019", "Midlothian") ~ "20",
    c("S12000020", "Moray") ~ "21",
    c("S12000021", "North Ayrshire") ~ "22",
    c("S12000044", "S12000050", "North Lanarkshire") ~ "23",
    c("S12000023", "Orkney") ~ "24",
    c("S12000024", "S12000048", "Perth and Kinross") ~ "25",
    c("S12000038", "Renfrewshire") ~ "26",
    c("S12000027", "Shetland Islands") ~ "27",
    c("S12000028", "South Ayrshire") ~ "28",
    c("S12000029", "South Lanarkshire") ~ "29",
    c("S12000030", "Stirling") ~ "30",
    c("S12000040", "West Lothian") ~ "31",
    c("S12000013", "Na h-Eileanan Siar", "Comhairle nan Eilean Siar") ~ "32"
  )
  return(lca)
}
