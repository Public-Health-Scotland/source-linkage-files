#' Convert Council Areas into Local Council Authority Codes
#'
#' @param ca vector of council area codes
#'
#' @return a vector of local council codes
#' @export
#'
#' @examples
#' ca <- c("S12000033", "S12000034")
#' ca_to_lca(ca)
ca_to_lca <- function(ca) {
      lca = case_when(
        ca == "S12000033" ~ "01", # Aberdeen City
        ca == "S12000034" ~ "02", # Aberdeenshire
        ca == "S12000041" ~ "03", # Angus
        ca == "S12000035" ~ "04", # Argyll and Bute
        ca == "S12000026" ~ "05", # Scottish Borders
        ca == "S12000005" ~ "06", # Clackmannanshire
        ca == "S12000039" ~ "07", # West Dun
        ca == "S12000006" ~ "08", # Dumfies and Galloway
        ca == "S12000042" ~ "09", # Dundee City
        ca == "S12000008" ~ "10", # East Ayrshire
        ca == "S12000045" ~ "11", # East Dun
        ca == "S12000010" ~ "12", # East Lothian
        ca == "S12000011" ~ "13", # East Ren
        ca == "S12000036" ~ "14", # City of Edinburgh
        ca == "S12000014" ~ "15", # Falkirk
        ca == "S12000047" ~ "16", # Fife
        ca == "S12000049" ~ "17", # Glasgow City
        ca == "S12000017" ~ "18", # Highland
        ca == "S12000018" ~ "19", # Inverclyde
        ca == "S12000019" ~ "20", # Midlothian
        ca == "S12000020" ~ "21", # Moray
        ca == "S12000021" ~ "22", # North Ayrshire
        ca == "S12000050" ~ "23", # North Lan
        ca == "S12000023" ~ "24", # Orkney
        ca == "S12000048" ~ "25", # P & K
        ca == "S12000038" ~ "26", # Renfrewshire
        ca == "S12000027" ~ "27", # Shetland
        ca == "S12000028" ~ "28", # South Ayrshire
        ca == "S12000029" ~ "29", # South Lan
        ca == "S12000030" ~ "30", # Stirling
        ca == "S12000040" ~ "31", # West Lothian
        ca == "S12000013" ~ "32" # Na h-Eileanan Siar
      )
      return(lca)
}



# library(phsopendata)

# ca_codes <- readr::read_csv(
#    "https://www.opendata.nhs.scot/dataset/9f942fdb-e59e-44f5-b534-d6e17229cc7b/resource/967937c4-8d67-4f39-974f-fd58c4acfda5/download/ca11_ca19.csv")

# ca <- phsopendata::opendata_get_resource(res_id = "967937c4-8d67-4f39-974f-fd58c4acfda5")
## phs package not working
