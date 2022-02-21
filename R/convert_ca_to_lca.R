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
  locality_file %>%
    mutate(
      lca = case_when(
      ca2019 == "S12000033" ~ "01", # Aberdeen City
      ca2019 == "S12000034" ~ "02", # Aberdeenshire
      ca2019 == "S12000041" ~ "03", # Angus
      ca2019 == "S12000035" ~ "04", # Argyll and Bute
      ca2019 == "S12000026" ~ "05", # Scottish Borders
      ca2019 == "S12000005" ~ "06", # Clackmannanshire
      ca2019 == "S12000039" ~ "07", # West Dun
      ca2019 == "S12000006" ~ "08", # Dumfies and Galloway
      ca2019 == "S12000042" ~ "09", # Dundee City
      ca2019 == "S12000008" ~ "10", # East Ayrshire
      ca2019 == "S12000045" ~ "11", # East Dun
      ca2019 == "S12000010" ~ "12", # East Lothian
      ca2019 == "S12000011" ~ "13", # East Ren
      ca2019 == "S12000036" ~ "14", # City of Edinburgh
      ca2019 == "S12000014" ~ "15", # Falkirk
      ca2019 == "S12000047" ~ "16", # Fife
      ca2019 == "S12000049" ~ "17", # Glasgow City
      ca2019 == "S12000017" ~ "18", # Highland
      ca2019 == "S12000018" ~ "19", # Inverclyde
      ca2019 == "S12000019" ~ "20", # Midlothian
      ca2019 == "S12000020" ~ "21", # Moray
      ca2019 == "S12000021" ~ "22", # North Ayrshire
      ca2019 == "S12000050" ~ "23", # North Lan
      ca2019 == "S12000023" ~ "24", # Orkney
      ca2019 == "S12000048" ~ "25", # P & K
      ca2019 == "S12000038" ~ "26", # Renfrewshire
      ca2019 == "S12000027" ~ "27", # Shetland
      ca2019 == "S12000028" ~ "28", # South Ayrshire
      ca2019 == "S12000029" ~ "29", # South Lan
      ca2019 == "S12000030" ~ "30", # Stirling
      ca2019 == "S12000040" ~ "31", # West Lothian
      ca2019 == "S12000013" ~ "32" # Na h-Eileanan Siar
      )
    )
}



# library(phsopendata)

# ca_codes <- readr::read_csv(
#    "https://www.opendata.nhs.scot/dataset/9f942fdb-e59e-44f5-b534-d6e17229cc7b/resource/967937c4-8d67-4f39-974f-fd58c4acfda5/download/ca11_ca19.csv")

#ca <- phsopendata::opendata_get_resource(res_id = "967937c4-8d67-4f39-974f-fd58c4acfda5")
## phs package not working
