#' Convert HSCP Codes to Names
#'
#' @description Convert Health & Social Care Partnership Codes to the
#' Health & Social Care Partnership Name.
#'
#' @param hscp vector of HSCP codes
#'
#' @return a vector of HSCP names
#' @export
#'
#' @examples
#' hscp <- c("S37000001", "S37000002")
#' convert_hscp_to_hscpnames(hscp)
#'
#' @family code functions
convert_hscp_to_hscpnames <- function(hscp) {
  hscpnames <- dplyr::case_match(
    hscp,
    "S37000001" ~ "Aberdeen City",
    "S37000002" ~ "Aberdeenshire",
    "S37000003" ~ "Angus",
    "S37000004" ~ "Argyll and Bute",
    "S37000005" ~ "Clackmannanshire and Stirling",
    "S37000006" ~ "Dumfries and Galloway",
    "S37000007" ~ "Dundee City",
    "S37000008" ~ "East Ayrshire",
    "S37000009" ~ "East Dunbartonshire",
    "S37000010" ~ "East Lothian",
    "S37000011" ~ "East Renfrewshire",
    "S37000012" ~ "Edinburgh",
    "S37000013" ~ "Falkirk",
    "S37000016" ~ "Highland",
    "S37000017" ~ "Inverclyde",
    "S37000018" ~ "Midlothian",
    "S37000019" ~ "Moray",
    "S37000020" ~ "North Ayrshire",
    "S37000022" ~ "Orkney Islands",
    "S37000024" ~ "Renfrewshire",
    "S37000025" ~ "Scottish Borders",
    "S37000026" ~ "Shetland Islands",
    "S37000027" ~ "South Ayrshire",
    "S37000028" ~ "South Lanarkshire",
    "S37000029" ~ "West Dunbartonshire",
    "S37000030" ~ "West Lothian",
    "S37000031" ~ "Western Isles",
    "S37000032" ~ "Fife",
    "S37000033" ~ "Perth and Kinross",
    "S37000034" ~ "Glasgow City",
    "S37000035" ~ "North Lanarkshire")
  return(hscpnames)
}


#' Convert NHS Health Board Codes to Names
#'
#' @description Convert NHS Health Board Codes to the NHS Health Board Names
#'
#' @param hb vector of NHS Health Board codes
#'
#' @return a vector of NHS Health Board names
#' @export
#'
#' @examples
#' hb <- c("S08000015", "S08000016")
#' convert_hb_to_hbnames(hb)
#'
#' @family code functions
convert_hb_to_hbnames <- function(hb) {
  hbnames <- dplyr::case_match(
    hb,
    "S08000015" ~ "Ayrshire and Arran",
    "S08000016" ~ "Borders",
    "S08000017" ~ "Dumfries and Galloway",
    "S08000019" ~ "Forth Valley",
    "S08000020" ~ "Grampian",
    "S08000022" ~ "Highland",
    "S08000024" ~ "Lothian",
    "S08000025" ~ "Orkney",
    "S08000026" ~ "Shetland",
    "S08000028" ~ "Western Isles",
    "S08000029" ~ "Fife",
    "S08000030" ~ "Tayside",
    "S08000031" ~ "Greater Glasgow and Clyde",
    "S08000032" ~ "Lanarkshire"
  )
  return(hbnames)
}
