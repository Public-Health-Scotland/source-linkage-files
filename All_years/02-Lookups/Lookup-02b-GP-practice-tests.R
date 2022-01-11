library(tidyverse)
library(dplyr)
library(haven)
library(fs)
library(glue)

#######################################################################
# Functions needed for testing
#######################################################################

#' General SLF directory for accessing HSCDIIP folders/files
#'
#' @return The path to the main SLF Extracts folder
#' @export
get_slf_dir <- function() {
  slf_dir <- fs::path("/conf/hscdiip/SLF_Extracts")

  return(slf_dir)
}

#' Get the latest update
#'
#' @return Latest update as MMM_YYYY
#' @export
latest_update <- function() {
  "Dec_2021"
}

#' Get the latest update
#'
#' @return Latest update as MMM_YYYY
#' @export
previous_update <- function() {
  "Sep_2021"
}


#' Function for lookups directory - source postcode and gpprac lookup
#' @param type the name of lookups within lookup directory
#'
#' @return The data as a tibble read using `haven::read_sav`
#' @export
read_old_lookups_dir <- function(type = c("postcode", "gpprac")) {
  lookups_dir <- "Lookups"

  lookups_name <- dplyr::case_when(
    type == "postcode" ~ "source_postcode_lookup_",
    type == "gpprac" ~ "source_GPprac_lookup_"
  )

  lookups_file_path <- fs::path(
    get_slf_dir(),
    lookups_dir,
    paste0(lookups_name, previous_update())
  )

  lookups_file_path <- fs::path_ext_set(
    lookups_file_path,
    "zsav"
  )

  return(haven::read_sav(lookups_file_path))
}


#' Function for lookups directory - source postcode and gpprac lookup
#' @param type the name of lookups within lookup directory
#'
#' @return The data as a tibble read using `haven::read_sav`
#' @export
read_new_lookups_dir <- function(type = c("postcode", "gpprac"), update = latest_update()) {
  lookups_dir <- "Lookups"

  lookups_name <- dplyr::case_when(
    type == "postcode" ~ "source_postcode_lookup_",
    type == "gpprac" ~ "source_GPprac_lookup_"
  )

  lookups_file_path <- fs::path(
    get_slf_dir(),
    lookups_dir,
    paste0(lookups_name, update)
  )

  lookups_file_path <- fs::path_ext_set(
    lookups_file_path,
    "zsav"
  )

  return(haven::read_sav(lookups_file_path))
}

#######################################################################

new_gpprac_lookup <- read_new_lookups_dir("gpprac")
old_gpprac_lookup <- read_new_lookups_dir("gpprac", update = previous_update())

gpprac_tests <- function(data, type = c("new", "old")) {
  data <- data %>%
    mutate(
      NHS_Ayrshire_and_Arran = if_else(hbpraccode == "S08000015", 1, 0),
      NHS_Borders = if_else(hbpraccode == "S08000016", 1, 0),
      NHS_Dumfries_and_Galloway = if_else(hbpraccode == "S08000017", 1, 0),
      NHS_Forth_Valley = if_else(hbpraccode == "S08000019", 1, 0),
      NHS_Grampian = if_else(hbpraccode == "S08000020", 1, 0),
      NHS_Greater_Glasgow_and_Clyde = if_else(hbpraccode == "S08000021", 1, 0),
      NHS_Highland = if_else(hbpraccode == "S08000022", 1, 0),
      NHS_Lanarkshire = if_else(hbpraccode == "S08000023", 1, 0),
      NHS_Lothian = if_else(hbpraccode == "S08000024", 1, 0),
      NHS_Orkney = if_else(hbpraccode == "S08000025", 1, 0),
      NHS_Shetland = if_else(hbpraccode == "S08000026", 1, 0),
      NHS_Western_Isles = if_else(hbpraccode == "S08000028", 1, 0),
      NHS_Fife = if_else(hbpraccode == "S08000029", 1, 0),
      NHS_Tayside = if_else(hbpraccode == "S08000030", 1, 0),
      Aberdeen_City = if_else(HSCP2018 == "S37000001", 1, 0),
      Aberdeenshire = if_else(HSCP2018 == "S37000002", 1, 0),
      Angus = if_else(HSCP2018 == "S37000003", 1, 0),
      Argyll_and_Bute = if_else(HSCP2018 == "S37000004", 1, 0),
      Clackmannanshire_and_Stirling = if_else(HSCP2018 == "S37000005", 1, 0),
      Dumfries_and_Galloway = if_else(HSCP2018 == "S37000006", 1, 0),
      Dundee_City = if_else(HSCP2018 == "S37000007", 1, 0),
      East_Ayrshire = if_else(HSCP2018 == "S37000008", 1, 0),
      East_Dunbartonshire = if_else(HSCP2018 == "S37000009", 1, 0),
      East_Lothian = if_else(HSCP2018 == "S37000010", 1, 0),
      East_Renfrewshire = if_else(HSCP2018 == "S37000011", 1, 0),
      Edinburgh = if_else(HSCP2018 == "S37000012", 1, 0),
      Falkirk = if_else(HSCP2018 == "S37000013", 1, 0),
      Glasgow_City = if_else(HSCP2018 == "S37000015", 1, 0),
      Highland = if_else(HSCP2018 == "S37000016", 1, 0),
      Inverclyde = if_else(HSCP2018 == "S37000017", 1, 0),
      Midlothian = if_else(HSCP2018 == "S37000018", 1, 0),
      Moray = if_else(HSCP2018 == "S37000019", 1, 0),
      North_Ayrshire = if_else(HSCP2018 == "S37000020", 1, 0),
      North_Lanarkshire = if_else(HSCP2018 == "S37000021", 1, 0),
      Orkney_Islands = if_else(HSCP2018 == "S37000022", 1, 0),
      Renfrewshire = if_else(HSCP2018 == "S37000024", 1, 0),
      Scottish_Borders = if_else(HSCP2018 == "S37000025", 1, 0),
      Shetland_Islands = if_else(HSCP2018 == "S37000026", 1, 0),
      South_Ayrshire = if_else(HSCP2018 == "S37000027", 1, 0),
      South_Lanarkshire = if_else(HSCP2018 == "S37000028", 1, 0),
      West_Dunbartonshire = if_else(HSCP2018 == "S37000029", 1, 0),
      West_Lothian = if_else(HSCP2018 == "S37000030", 1, 0),
      Western_Isles = if_else(HSCP2018 == "S37000031", 1, 0),
      Fife = if_else(HSCP2018 == "S37000032", 1, 0),
      Perth_and_Kinross = if_else(HSCP2018 == "S37000033", 1, 0),
      n_gpprac = 1
    ) %>%
    summarise(across(everything(), sum, na.rm = TRUE)) %>%
    pivot_longer(
      cols = everything(),
      names_to = "measure",
      values_to = "value"
    )
}

new_tests <- gpprac_tests(read_new_lookups_dir("gpprac"))
old_tests <- gpprac_tests(read_new_lookups_dir("gpprac", update = previous_update()))

compare_tests <- function(old_data, new_data) {
  full_join(old_data, new_data, by = "measure", suffix = c("_old", "_new")) %>%
    mutate(diff = value_old - value_new)
}
