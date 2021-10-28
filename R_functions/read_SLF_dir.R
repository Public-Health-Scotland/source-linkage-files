#' General SLF directory for accessing HSCDIIP folders/files
#'
#' @return The path to the main SLF Extracts folder
#' @export
get_slf_dir <- function() {
  slf_dir <- fs::path("/conf/hscdiip/SLF_Extracts")

  return(slf_dir)
}

#' Function for delayed discharges directory
#'
#' @return Reads the DD file (sav)
#' @export
read_dd_file <- function() {
  dd_dir <- "Delayed_Discharges"

  dd_name <- "DD_LinkageFile"

  dd_file_path <- fs::path(
    get_slf_dir(),
    dd_dir,
    paste0(
      dd_period(),
      dd_name
    )
  )
  dd_file_path <- fs::path_ext_set(
    dd_file_path,
    "zsav"
  )

  return(haven::read_sav(dd_file_path))
}

#' Function for lookups directory - source postcode and gpprac lookup
#' @param type the name of lookups within lookup directory
#'
#' @return The data as a tibble read using `haven::read_sav`
#' @export
read_lookups_dir <- function(type = c("postcode", "gpprac")) {
  lookups_dir <- "Lookups"

  lookups_name <- dplyr::case_when(
    type == "postcode" ~ "source_postcode_lookup_",
    type == "gpprac" ~ "source_GPprac_lookup_"
  )

  lookups_file_path <- fs::path(
    get_slf_dir(),
    lookups_dir,
    paste0(lookups_name, latest_update())
  )
  lookups_file_path <- fs::path_ext_set(
    lookups_file_path,
    "zsav"
  )

  return(haven::read_sav(lookups_file_path))
}

#' Function for reading in GP cluster
#' lookup "Practice Details" for creating
#' source GP prac lookup above
#'
#' @param file_name Name of the file to be read
#'
#' @return The practice details file
#' @export
read_practice_details <- function(file_name = "Practice Details.sav") {
  practice_details_path <- fs::path(
    "/conf/hscdiip/SLF_Extracts/Lookups",
    file_name
  )

  practice_details_file <- haven::read_sav(practice_details_path)
  return(practice_details_file)
}

#' Function for cohorts directory - Demographic cohorts and Service Use cohorts
#' @param type The name of cohorts within cohort directory
#'
#' @return The data read using `haven::read_sav`
#' @export
read_cohorts_dir <- function(type = c("demographic", "service_use")) {
  cohorts_dir <- "Cohorts"

  cohorts_name <- dplyr::case_when(
    type == "demographic" ~ "Demographic_Cohorts_",
    type == "service_use" ~ "Service_Use_Cohorts_"
  )

  cohorts_file_path <- fs::path(get_slf_dir(), cohorts_dir, paste0(cohorts_name, year))
  cohorts_file_path <- fs::path_ext_set(cohorts_file_path, "zsav")


  cohorts_file <- haven::read_sav(cohorts_file_path)
  return(cohorts_file)
}

#' Function for costs directory - Reading CH, DN and GP OOH costs
#' @param type The name of costs lookup within costs directory
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' ch_costs <- read_costs_file("CH")
#' dn_costs <- read_sav(read_costs_dir("DN"))
#' ooh_costs <- read_sav(read_costs_dir("GPOOH"))
read_costs_dir <- function(type = c("CH", "DN", "GPOOH")) {
  costs_dir <- "Costs"

  costs_name <- dplyr::case_when(
    type == "CH" ~ "Cost_CH_Lookup",
    type == "DN" ~ "Cost_DN_Lookup",
    type == "GPOOH" ~ "Cost_GPOOH_Lookup"
  )

  costs_file_path <- fs::path(read_slf_dir(), costs_dir, costs_name)
  costs_file_path <- fs::path_ext_set(costs_file_path, "sav")

  return(haven::read_sav(costs_file_path))
}

#' Get the deaths file directory
#' @return
#' @export
#'
#' @examples
#' all_deaths <- read_deaths_dir()
read_deaths_dir <- function() {
  deaths_dir <- "Deaths"

  deaths_name <- "all_deaths_"


  deaths_file_path <- fs::path(
    get_slf_dir(),
    deaths_dir,
    paste0(deaths_name, latest_update())
  )
  deaths_file_path <- fs::path_ext_set(deaths_file_path, "zsav")

  return(haven::read_sav(deaths_file_path))
}

###################################################
# Function for HHG directory - reading HHG extract
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' hhg_file <- read_hhg_dir()
read_hhg_dir <- function() {
  hhg_dir <- "HHG"

  hhg_name <- "HHG-20"

  hhg_file <- fs::path(get_slf_dir(), hhg_dir, glue::glue("{hhg_name}{year}"))
  hhg_file <- fs::path_ext_set(hhg_file, "zsav")

  return(haven::read_sav(hhg_file))
}


###################################################
# Function for SPARRA directory - reading SPARRA extract
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' sparra_file <- read_sparra_dir()
read_sparra_dir <- function() {
  sparra_dir <- "SPARRA"

  sparra_name <- "SPARRA-20"

  sparra_file <- fs::path(get_slf_dir(), sparra_dir, glue::glue("{sparra_name}{year}"))
  sparra_file <- fs::path_ext_set(sparra_file, "zsav")

  return(haven::read_sav(sparra_file))
}


########################################################
# Function for NSU directory - stores NSU extracts for years that are available
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' nsu_file <- read_nsu_dir()
read_nsu_dir <- function() {
  nsu_dir <- "NSU/"

  nsu_name <- "All_CHIs_20"

  nsu_file <- fs::path(get_slf_dir(), nsu_dir, glue::glue("{nsu_name}{year}"))
  nsu_file <- fs::path_ext_set(nsu_file, "zsav")

  return(haven::read_sav(nsu_file))
}




########################################################
# Function for LTCs directory - stores LTC extracts for all years
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' ltc_file <- read_ltc_dir()
read_ltc_dir <- function() {
  ltc_dir <- "LTCs"

  ltc_name <- "LTCs_patient_reference_file-20"

  ltc_file <- fs::path(get_slf_dir(), ltc_dir, glue::glue("{ltc_name}{year}"))
  ltc_file <- fs::path_ext_set(ltc_file, "zsav")

  return(haven::read_sav(ltc_file))
}



########################################################
# Function for IT extract directory - stores IT extracts for all years
#'
#' @return
#' @export
#'
#' @examples
#' it_extract_1819 <- read_csv(file = read_it_extract_dir("1819"), n_max = 2000)
# initialise extract type
extract <- c("LTCs", "Deaths", "1516", "1617", "1718", "1819", "1920", "2021", "2122")

# create function with 'extract'
read_it_extract_dir <- function(extract) {
  it_extract_dir <- "IT_extracts/"

  csd_ref <- "SCTASK0247528_extract_"

  extract_name <- case_when(
    extract == "LTCs" ~ "1_LTCs",
    extract == "Deaths" ~ "2_Deaths",
    extract == "1516" ~ "3_2015",
    extract == "1617" ~ "4_2016",
    extract == "1718" ~ "5_2017",
    extract == "1819" ~ "6_2018",
    extract == "1920" ~ "7_2019",
    extract == "2021" ~ "8_2020",
    extract == "2122" ~ "9_2021"
  )

  it_extract_file <- glue::glue("{read_slf_dir()}{it_extract_dir}{csd_ref}{extract_name}.csv.gz")

  return(it_extract_file)
}


# Path not working with .csv.gz - look into this!

# End of Script
########################################################
# Still work in progress. Saving notes below
########################################################
#Lookups folder
    #Saves out GP prac lookup and postcode lookup
#Costs folder
    #Derives costs lookup for GP OOH, CH and DN
    #Separate syntax stored in here
    #SLFs calls upon costs lookup and matches back onto SLFs
#Delayed Discharges folder
    #Stores linkage file extract and corrected end dates
#IT_extracts
    #Stores IT extracts for each year
#HHG
    #Stores HHG files
#SPARRA
    #Stores SPARRA files
#NSU
    #Stores NSU file for each year available
      #(2015/16 onwards)
      #(No NSU for latest years)
#Cohorts
    #Stores Demographic/Service use cohorts
#LTCs
    #Stores LTC file
#Deaths
    #Stores All Deaths file

#Create simple functions
#e.g. Delayed discharges file = Just file path to DD file
    #Postcode lookup file
    #GPprac lookup file

#Set up works but needs to be more vague for inputting files.
#e.g. IT Extracts numbers
#GP prac lookup and postcode lookup stored in lookups folder.
read_SLF_dir <- function(type = c("Lookups", "Costs", "Delayed_Discharges", "IT_extracts", "HHG",
                                  "NSU", "SPARRA", "Cohorts", "LTCs", "Deaths", "Social_care"), file) {
  SLF_dir_path <- fs::path("/conf/hscdiip/SLF_Extracts/", type, file)
}

#Test read_SLF_dir function
#These Two are working with above
#Delayed_discharges_file <- read_sav(read_SLF_dir("Delayed_Discharges", "Jul16_Jun21DD_LinkageFile.zsav"))
#postcode_lookup_file <- read_sav(read_SLF_dir("Lookups", "source_postcode_lookup_Sep_2021.zsav"))
#Example of something else we could do
#postcode_lookup_file <- read_sav(read_SLF_dir("Lookups", glue::glue("source_postcode_lookup_{latest_update()}.zsav")))
