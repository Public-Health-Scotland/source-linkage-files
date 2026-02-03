# run_sdl.R for testing

# First step rename current dataset so it is not overwritten.####
# will need to change/remove renaming step once switched to seer

# 00 setup logger ----
logger::log_info("Run SDL starts.")

library(createslf)

library(DBI)
library(arrow)
library(data.table)
library(dbplyr)
library(dplyr)
library(fs)
library(hms)
library(janitor)
library(keyring)
library(lubridate)
library(magrittr)
library(odbc)
library(openxlsx)
library(phsmethods)
library(phsopendata)
library(purrr)
library(readr)
library(rlang)
library(rmarkdown)
library(readxl)
library(rstudioapi)
library(slfhelper)
library(stringdist)
library(stringr)
library(tibble)
library(tidyr)
library(tidyselect)
library(zoo)
library(knitr)
library(roxygen2)
library(scales)
library(spelling)
library(tarchetypes)
library(targets)
library(testthat)
library(crew)

# prepare necessary data
# notes fy format
year <- "2017"

# set up logger and system environment variable BYOC_MODE
if (exists("BYOC_MODE") && isTRUE(BYOC_MODE)) {
  logger::log_info("Detect run_sdl.r run on Denodo")
  Sys.setenv(BYOC_MODE = "TRUE")
} else {
  logger::log_info("Detect run_sdl.r run locally")
  BYOC_MODE <- FALSE
  Sys.setenv(BYOC_MODE = "FALSE")
}


# setup connection to Denodo if run locally
if (!BYOC_MODE) {
  # Open a connection to DVPREPROD (test environment) or DVPROD (production environment)
  denodo_connect <- suppressWarnings(dbConnect(
    odbc(),
    dsn = "DVPREPROD",
    # or DVPROD
    uid = .rs.askForPassword("Enter your username"),
    pwd = .rs.askForPassword("Enter your LDAP password")
  ))
}


write_to_disk <- TRUE

## create dummy data for testing -----
# hard coded dummy data
# TODO: remove this
la_code_lookup <- data.frame(
  CA = c(
    "S12000005", "S12000006", "S12000008", "S12000010", "S12000011",
    "S12000013", "S12000014", "S12000015", "S12000017", "S12000018",
    "S12000019", "S12000020", "S12000021", "S12000023", "S12000024",
    "S12000026", "S12000027", "S12000028", "S12000029", "S12000030",
    "S12000033", "S12000034", "S12000035", "S12000036", "S12000038",
    "S12000039", "S12000040", "S12000041", "S12000042", "S12000044",
    "S12000045", "S12000046", "S12000047", "S12000048", "S12000049",
    "S12000050"
  ),
  CAName = c(
    "Clackmannanshire", "Dumfries and Galloway", "East Ayrshire",
    "East Lothian", "East Renfrewshire", "Na h-Eileanan Siar",
    "Falkirk", "Fife", "Highland", "Inverclyde", "Midlothian", "Moray",
    "North Ayrshire", "Orkney Islands", "Perth and Kinross",
    "Scottish Borders", "Shetland Islands", "South Ayrshire",
    "South Lanarkshire", "Stirling", "Aberdeen City", "Aberdeenshire",
    "Argyll and Bute", "City of Edinburgh", "Renfrewshire",
    "West Dunbartonshire", "West Lothian", "Angus", "Dundee City",
    "North Lanarkshire", "East Dunbartonshire", "Glasgow City",
    "Fife", "Perth and Kinross", "Glasgow City", "North Lanarkshire"
  ),
  sending_local_authority_name = c(
    "Clackmannanshire", "Dumfries & Galloway", "East Ayrshire",
    "East Lothian", "East Renfrewshire", "Eilean Siar", "Falkirk",
    "Fife", "Highland", "Inverclyde", "Midlothian", "Moray",
    "North Ayrshire", "Orkney Islands", "Perth & Kinross",
    "Scottish Borders", "Shetland Islands", "South Ayrshire",
    "South Lanarkshire", "Stirling", "Aberdeen City", "Aberdeenshire",
    "Argyll & Bute", "Edinburgh", "Renfrewshire", "West Dunbartonshire",
    "West Lothian", "Angus", "Dundee City", "North Lanarkshire",
    "East Dunbartonshire", "Glasgow City", "Fife", "Perth & Kinross",
    "Glasgow City", "North Lanarkshire"
  ),
  stringsAsFactors = FALSE
)

set.seed(1)
sg_pub_data <- data.frame(
  CAName = c(
    "Aberdeen City", "Aberdeen City", "Aberdeen City", "Aberdeen City", "Aberdeen City", "Aberdeen City", "Aberdeen City", "Aberdeen City", "Aberdeen City",
    "Aberdeenshire", "Aberdeenshire", "Aberdeenshire", "Aberdeenshire", "Aberdeenshire", "Aberdeenshire", "Aberdeenshire", "Aberdeenshire", "Aberdeenshire",
    "Angus", "Angus", "Angus", "Angus", "Angus", "Angus", "Angus", "Angus", "Angus",
    "Argyll & Bute", "Argyll & Bute", "Argyll & Bute", "Argyll & Bute", "Argyll & Bute", "Argyll & Bute", "Argyll & Bute", "Argyll & Bute", "Argyll & Bute",
    "Clackmannanshire", "Clackmannanshire", "Clackmannanshire", "Clackmannanshire", "Clackmannanshire", "Clackmannanshire", "Clackmannanshire", "Clackmannanshire", "Clackmannanshire",
    "Dumfries & Galloway", "Dumfries & Galloway", "Dumfries & Galloway", "Dumfries & Galloway", "Dumfries & Galloway", "Dumfries & Galloway", "Dumfries & Galloway", "Dumfries & Galloway", "Dumfries & Galloway",
    "Dundee City", "Dundee City", "Dundee City", "Dundee City", "Dundee City", "Dundee City", "Dundee City", "Dundee City", "Dundee City",
    "East Ayrshire", "East Ayrshire", "East Ayrshire", "East Ayrshire", "East Ayrshire", "East Ayrshire", "East Ayrshire", "East Ayrshire", "East Ayrshire",
    "East Dunbartonshire", "East Dunbartonshire", "East Dunbartonshire", "East Dunbartonshire", "East Dunbartonshire", "East Dunbartonshire", "East Dunbartonshire", "East Dunbartonshire", "East Dunbartonshire",
    "East Lothian", "East Lothian", "East Lothian", "East Lothian", "East Lothian", "East Lothian", "East Lothian", "East Lothian", "East Lothian",
    "East Renfrewshire", "East Renfrewshire", "East Renfrewshire", "East Renfrewshire", "East Renfrewshire", "East Renfrewshire", "East Renfrewshire", "East Renfrewshire", "East Renfrewshire",
    "Edinburgh", "Edinburgh", "Edinburgh", "Edinburgh", "Edinburgh", "Edinburgh", "Edinburgh", "Edinburgh", "Edinburgh",
    "Eilean Siar", "Eilean Siar", "Eilean Siar", "Eilean Siar", "Eilean Siar", "Eilean Siar", "Eilean Siar", "Eilean Siar", "Eilean Siar",
    "Falkirk", "Falkirk", "Falkirk", "Falkirk", "Falkirk", "Falkirk", "Falkirk", "Falkirk", "Falkirk",
    "Fife", "Fife", "Fife", "Fife", "Fife", "Fife", "Fife", "Fife", "Fife",
    "Glasgow City", "Glasgow City", "Glasgow City", "Glasgow City", "Glasgow City", "Glasgow City", "Glasgow City", "Glasgow City", "Glasgow City",
    "Highland", "Highland", "Highland", "Highland", "Highland", "Highland", "Highland", "Highland", "Highland",
    "Inverclyde", "Inverclyde", "Inverclyde", "Inverclyde", "Inverclyde", "Inverclyde", "Inverclyde", "Inverclyde", "Inverclyde",
    "Midlothian", "Midlothian", "Midlothian", "Midlothian", "Midlothian", "Midlothian", "Midlothian", "Midlothian", "Midlothian",
    "Moray", "Moray", "Moray", "Moray", "Moray", "Moray", "Moray", "Moray", "Moray",
    "North Ayrshire", "North Ayrshire", "North Ayrshire", "North Ayrshire", "North Ayrshire", "North Ayrshire", "North Ayrshire", "North Ayrshire", "North Ayrshire",
    "North Lanarkshire", "North Lanarkshire", "North Lanarkshire", "North Lanarkshire", "North Lanarkshire", "North Lanarkshire", "North Lanarkshire", "North Lanarkshire", "North Lanarkshire",
    "Orkney", "Orkney", "Orkney", "Orkney", "Orkney", "Orkney", "Orkney", "Orkney", "Orkney",
    "Perth & Kinross", "Perth & Kinross", "Perth & Kinross", "Perth & Kinross", "Perth & Kinross", "Perth & Kinross", "Perth & Kinross", "Perth & Kinross", "Perth & Kinross",
    "Renfrewshire", "Renfrewshire", "Renfrewshire", "Renfrewshire", "Renfrewshire", "Renfrewshire", "Renfrewshire", "Renfrewshire", "Renfrewshire",
    "Scottish Borders", "Scottish Borders", "Scottish Borders", "Scottish Borders", "Scottish Borders", "Scottish Borders", "Scottish Borders", "Scottish Borders", "Scottish Borders",
    "Shetland", "Shetland", "Shetland", "Shetland", "Shetland", "Shetland", "Shetland", "Shetland", "Shetland",
    "South Ayrshire", "South Ayrshire", "South Ayrshire", "South Ayrshire", "South Ayrshire", "South Ayrshire", "South Ayrshire", "South Ayrshire", "South Ayrshire",
    "South Lanarkshire", "South Lanarkshire", "South Lanarkshire", "South Lanarkshire", "South Lanarkshire", "South Lanarkshire", "South Lanarkshire", "South Lanarkshire", "South Lanarkshire",
    "Stirling", "Stirling", "Stirling", "Stirling", "Stirling", "Stirling", "Stirling", "Stirling", "Stirling",
    "West Dunbartonshire", "West Dunbartonshire", "West Dunbartonshire", "West Dunbartonshire", "West Dunbartonshire", "West Dunbartonshire", "West Dunbartonshire", "West Dunbartonshire", "West Dunbartonshire",
    "West Lothian", "West Lothian", "West Lothian", "West Lothian", "West Lothian", "West Lothian", "West Lothian", "West Lothian", "West Lothian"
  ),
  sg_year = rep(c("1617", "1718", "1819", "1920", "2021", "2122", "2223", "2324", "2425"), times = 32),
  sg_all_assessments = sample(120:9000, size = 32 * 9, replace = TRUE),
  stringsAsFactors = FALSE
)


# just test one year
year <- "2019"

# targets::tar_make()

# test homelessness data only
## create homelessness data ----
logger::log_info("Read and process homelessness data")
hl1 <- read_extract_homelessness(
  year,
  denodo_connect = denodo_connect,
  BYOC_MODE = BYOC_MODE
) %>% process_extract_homelessness(
  year = year,
  write_to_disk = write_to_disk,
  la_code_lookup = la_code_lookup,
  sg_pub_data = sg_pub_data,
  BYOC_MODE = BYOC_MODE
)

## disconnect from denodo if run locally ----
if (!BYOC_MODE) {
  logger::log_info("Disconnect from Denodo")
  DBI::dbDisconnect(denodo_connect)
}
