#General SLF directory for accessing HSCDIIP folders/files
#' @param () - String containing SLF directory file path
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' read_slf_dir()
read_slf_dir <- function(){
  slf_dir <- "/conf/hscdiip/SLF_Extracts/"

  return(slf_dir)
}

####################################################
#Function for delayed discharges directory
#' @param dd_dir - the name of the SLF directory
#'
#' @return The data read using `readr::read_rds``
#' @export
#'
#' @examples
#' delayed_discharges_file <- read_sav(read_dd_file())

#Function for reading in delayed discharges file
read_dd_file <- function() {
 dd_dir <- "Delayed_Discharges/"

 delayed_discharges_file<- glue::glue("{read_slf_dir()}{dd_dir}{dd_period()}DD_LinkageFile.zsav")

  return(delayed_discharges_file)
}


####################################################
#Function for lookups directory - source postcode and gpprac lookup
#' @param `type`` - the name of lookups within lookup directory
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#'source_pc_lookup <- read_sav(read_lookups_dir("postcode"))
#'source_gpprac_lookup <- read_sav(read_lookups_dir("gpprac"))
read_lookups_dir <- function(type = c("postcode", "gpprac")) {
  lookups_dir <- "Lookups/"

  lookups_name <- case_when(type == "postcode" ~ "source_postcode_lookup_",
                            type == "gpprac" ~ "source_GPprac_lookup_"
                            )
  lookups_file <- glue::glue("{read_slf_dir()}{lookups_dir}{lookups_name}{latest_update()}.zsav")

  return(lookups_file)
}


#Function for reading in GP cluster lookup "Practice Details" for creating source GP prac lookup above
read_practice_details <- function() {
  practice_details <- "/conf/hscdiip/SLF_Extracts/Lookups/Practice Details.sav"

  return(practice_details)
}

####################################################
#Function for cohorts directory - Demographic cohorts and Service Use cohorts
#' @param `type`` - the name of cohorts within cohort directory
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#'demographic_cohorts <- read_sav(read_cohorts_dir("demographic"))
#'service_use_cohorts <- read_sav(read_cohorts_dir("service_use"))

read_cohorts_dir <- function(type = c("demographic","service_use")){
  cohorts_dir <- "Cohorts/"

  cohorts_name <- case_when(type == "demographic" ~ "Demographic_Cohorts_",
                            type == "service_use" ~ "Service_Use_Cohorts_"
                            )
  cohorts_file <- glue::glue("{read_slf_dir()}{cohorts_dir}{cohorts_name}{year}.zsav")

  return(cohorts_file)
}


####################################################
#Function for costs directory - Reading CH, DN and GP OOH costs
#' @param `type`` - the name of costs lookup within costs directory
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#'ch_costs <- read_sav(read_costs_dir("CH"))
#'dn_costs <- read_sav(read_costs_dir("DN"))
#'ooh_costs <- read_sav(read_costs_dir("GPOOH"))

read_costs_dir <- function(type = c("CH", "DN", "GPOOH")) {
  costs_dir <- "Costs/"

  costs_name <- case_when(type == "CH" ~ "Cost_CH_Lookup",
                          type == "DN" ~ "Cost_DN_Lookup",
                          type == "GPOOH" ~ "Cost_GPOOH_Lookup"
                          )

  costs_file <- glue::glue("{read_slf_dir()}{costs_dir}{costs_name}.sav")

  return(costs_file)
}

###################################################
#Function for deaths directory - saving/reading the all deaths file
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' all_deaths <- read_sav(read_deaths_dir())
read_deaths_dir <- function() {
  deaths_dir <- "Deaths/"

  deaths_name <- "all_deaths_"

  deaths_file <- glue::glue("{read_slf_dir()}{deaths_dir}{deaths_name}{latest_update()}.zsav")

  return(deaths_file)
}

###################################################
#Function for HHG directory - reading HHG extract
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' hhg_file <- read_sav(read_hhg_dir())
read_hhg_dir<- function() {
  hhg_dir <- "HHG/"

  hhg_file <- glue::glue("{read_slf_dir()}{hhg_dir}HHG-20{year}.zsav")

  return(hhg_file)
}



###################################################
#Function for SPARRA directory - reading SPARRA extract
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' sparra_file <- read_sav(read_sparra_dir())
read_sparra_dir <- function() {
  sparra_dir <- "SPARRA/"

  sparra_file <- glue::glue("{read_slf_dir()}{sparra_dir}SPARRA-20{year}.zsav")

  return(sparra_file)
}


########################################################
#Function for NSU directory - stores NSU extracts for years that are available
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' nsu_file <- read_sav(read_nsu_dir())
read_nsu_dir <- function() {
  nsu_dir <- "NSU/"

  nsu_file <- glue::glue("{read_slf_dir()}{nsu_dir}All_CHIs_20{year}.zsav")

  return(nsu_file)
}


########################################################
#Function for LTCs directory - stores LTC extracts for all years
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' ltc_file <- read_sav(read_ltc_dir())
read_ltc_dir <- function(){
  ltc_dir <- "LTCs/"

  ltc_file <- glue::glue("{read_slf_dir()}{ltc_dir}LTCs_patient_reference_file-20{year}.zsav")

  return(ltc_file)
}


ltc_file <- read_sav(read_ltc_dir())


########################################################
#Function for IT extract directory - stores IT extracts for all years
#' @param ()
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' it_extract_1819 <- read_csv(file = read_it_extract_dir("1819"), n_max = 2000)
#initialise extract type
extract <- c("LTCs", "Deaths", "1516", "1617", "1718", "1819", "1920", "2021", "2122")

#create function with 'extract'
read_it_extract_dir <- function(extract){
 it_extract_dir <- "IT_extracts/"

  csd_ref <- "SCTASK0247528_extract_"

  extract_name <- case_when(extract == "LTCs" ~ "1_LTCs",
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


#End of Script
########################################################
#Still work in progress. Saving notes below
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
  SLF_dir_path <- path("/conf/hscdiip/SLF_Extracts/", type, file)
}

#Test read_SLF_dir function
#These Two are working with above
#Delayed_discharges_file <- read_sav(read_SLF_dir("Delayed_Discharges", "Jul16_Jun21DD_LinkageFile.zsav"))
#postcode_lookup_file <- read_sav(read_SLF_dir("Lookups", "source_postcode_lookup_Sep_2021.zsav"))
#Example of something else we could do
#postcode_lookup_file <- read_sav(read_SLF_dir("Lookups", glue::glue("source_postcode_lookup_{latest_update()}.zsav")))
