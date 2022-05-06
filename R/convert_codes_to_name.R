#' Convert HSCP Codes to HSCP Names
#'
#' @param hscp vector of HSCP codes
#'
#' @return a vector of HSCP names
#' @export
#'
#' @examples
#' hscp <- c("S37000001", "S37000002")
#' hscp_to_hscpnames(hscp)
hscp_to_hscpnames <- function(hscp) {
  hscpnames <- dplyr::case_when(
    hscp == "S37000001" ~ "Aberdeen City",
    hscp == "S37000002" ~ "Aberdeenshire",
    hscp == "S37000003" ~ "Angus",
    hscp == "S37000004" ~ "Argyll and Bute",
    hscp == "S37000005" ~ "Clackmannanshire and Stirling",
    hscp == "S37000006" ~ "Dumfries and Galloway",
    hscp == "S37000007" ~ "Dundee City",
    hscp == "S37000008" ~ "East Ayrshire",
    hscp == "S37000009" ~ "East Dunbartonshire",
    hscp == "S37000010" ~ "East Lothian",
    hscp == "S37000011" ~ "East Renfrewshire",
    hscp == "S37000012" ~ "Edinburgh",
    hscp == "S37000013" ~ "Falkirk",
    hscp == "S37000016" ~ "Highland",
    hscp == "S37000017" ~ "Inverclyde",
    hscp == "S37000018" ~ "Midlothian",
    hscp == "S37000019" ~ "Moray",
    hscp == "S37000020" ~ "North Ayrshire",
    hscp == "S37000022" ~ "Orkney Islands",
    hscp == "S37000024" ~ "Renfrewshire",
    hscp == "S37000025" ~ "Scottish Borders",
    hscp == "S37000026" ~ "Shetland Islands",
    hscp == "S37000027" ~ "South Ayrshire",
    hscp == "S37000028" ~ "South Lanarkshire",
    hscp == "S37000029" ~ "West Dunbartonshire",
    hscp == "S37000030" ~ "West Lothian",
    hscp == "S37000031" ~ "Western Isles",
    hscp == "S37000032" ~ "Fife",
    hscp == "S37000033" ~ "Perth and Kinross",
    hscp == "S37000034" ~ "Glasgow City",
    hscp == "S37000035" ~ "North Lanarkshire"
  )
  return(hscpnames)
}


#' Convert NHS Health Board Codes to NHS Health Board Names
#'
#' @param hb vector of NHS Health Board codes
#'
#' @return a vector of NHS Health Board names
#' @export
#'
#' @examples
#' hb <- c("S08000015", "S08000016")
#' hb_to_hbnames(hb)
hb_to_hbnames <- function(hb) {
  hbnames <- dplyr::case_when(
    hb == "S08000015" ~ "Ayrshire and Arran",
    hb == "S08000016" ~ "Borders",
    hb == "S08000017" ~ "Dumfries and Galloway",
    hb == "S08000019" ~ "Forth Valley",
    hb == "S08000020" ~ "Grampian",
    hb == "S08000022" ~ "Highland",
    hb == "S08000024" ~ "Lothian",
    hb == "S08000025" ~ "Orkney",
    hb == "S08000026" ~ "Shetland",
    hb == "S08000028" ~ "Western Isles",
    hb == "S08000029" ~ "Fife",
    hb == "S08000030" ~ "Tayside",
    hb == "S08000031" ~ "Greater Glasgow and Clyde",
    hb == "S08000032" ~ "Lanarkshire"
  )

  return(hbnames)
}
