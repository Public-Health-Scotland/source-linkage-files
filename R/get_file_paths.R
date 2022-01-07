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
  dd_file_path <- fs::path(
    get_slf_dir(),
    "Delayed_Discharges",
    paste0(
      dd_period(),
      "DD_LinkageFile"
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
    get_slf_dir(),
    "Lookups",
    file_name
  )

  practice_details_file <- haven::read_sav(practice_details_path)
  return(practice_details_file)
}

#' Function for cohorts directory - Demographic cohorts and Service Use cohorts
#'
#' @param type The name of cohorts within cohort directory
#' @param year Year of cohort extracts
#' @param ... additional arguments passed to [haven::read_sav]
#'
#' @return The data read using [haven][haven::read_sav]
#' @export
read_cohorts_dir <- function(type = c("demographic", "service_use"), year, ...) {
  cohorts_dir <- "Cohorts"

  cohorts_name <- dplyr::case_when(
    type == "demographic" ~ "Demographic_Cohorts_",
    type == "service_use" ~ "Service_Use_Cohorts_"
  )

  cohorts_file_path <- fs::path(get_slf_dir(), cohorts_dir, paste0(cohorts_name, year))
  cohorts_file_path <- fs::path_ext_set(cohorts_file_path, "zsav")


  cohorts_file <- haven::read_sav(cohorts_file_path, ...)
  return(cohorts_file)
}

#' Function for costs directory - Reading CH, DN and GP OOH costs
#'
#' @param type The name of costs lookup within costs directory
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' \dontrun{
#' ch_costs <- read_costs_dir("CH")
#' dn_costs <- read_costs_dir("DN")
#' ooh_costs <- read_costs_dir("GPOOH")
#' }
read_costs_dir <- function(type = c("CH", "DN", "GPOOH")) {
  costs_dir <- "Costs"

  costs_name <- dplyr::case_when(
    type == "CH" ~ "Cost_CH_Lookup",
    type == "DN" ~ "Cost_DN_Lookup",
    type == "GPOOH" ~ "Cost_GPOoH_Lookup"
  )

  costs_file_path <- fs::path(get_slf_dir(), costs_dir, costs_name)
  costs_file_path <- fs::path_ext_set(costs_file_path, "sav")

  return(haven::read_sav(costs_file_path))
}

#' Get the deaths file directory
#'
#' @param ... additional arguments passed to [haven::read_sav]
#'
#' @return The Deaths file, read by [haven][haven::read_sav]
#' @export
#'
#' @examples
#' \dontrun{
#' all_deaths <- read_deaths_dir()
#' }
read_deaths_dir <- function(...) {
  deaths_file_path <- fs::path(
    get_slf_dir(),
    "Deaths",
    paste0("all_deaths_", latest_update())
  )
  deaths_file_path <- fs::path_ext_set(deaths_file_path, "zsav")

  return(haven::read_sav(deaths_file_path, ...))
}


#' Function for HHG directory - reading HHG extract
#'
#' @param year Yeah of extract
#' @param ... additional arguments passed to [haven::read_sav]
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' \dontrun{
#' hhg_file <- read_hhg_dir("1819")
#' }
read_hhg_dir <- function(year, ...) {
  hhg_file_path <- fs::path(
    get_slf_dir(),
    "HHG",
    paste0("HHG-20", year)
  )
  hhg_file_path <- fs::path_ext_set(hhg_file_path, "zsav")

  return(haven::read_sav(hhg_file_path, ...))
}

#' Function for SPARRA directory - reading SPARRA extract
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [haven::read_sav]
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' \dontrun{
#' sparra_file <- read_sparra_dir("1819")
#' }
read_sparra_dir <- function(year, ...) {
  sparra_dir <- "SPARRA"

  sparra_name <- "SPARRA-20"

  sparra_file_path <- fs::path(
    get_slf_dir(),
    sparra_dir,
    paste0(sparra_name, year)
  )
  sparra_file_path <- fs::path_ext_set(sparra_file_path, "zsav")

  return(haven::read_sav(sparra_file_path, ...))
}



#' Function for NSU directory - stores NSU extracts for years that are available
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [haven::read_sav]
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' \dontrun{
#' nsu_file <- read_nsu_dir("1819")
#' }
read_nsu_dir <- function(year, ...) {
  nsu_dir <- "NSU/"

  nsu_name <- "All_CHIs_20"

  nsu_file_path <- fs::path(
    get_slf_dir(),
    nsu_dir,
    paste0(nsu_name, year)
  )
  nsu_file_path <- fs::path_ext_set(nsu_file_path, "zsav")

  return(haven::read_sav(nsu_file_path, ...))
}



#' Function for LTCs directory - stores LTC extracts for all years
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [haven::read_sav]
#'
#' @return The data read using `haven::read_sav`
#' @export
#'
#' @examples
#' \dontrun{
#' ltc_file <- read_ltc_dir("1819")
#' }
read_ltc_dir <- function(year, ...) {
  ltc_dir <- "LTCs"

  ltc_name <- "LTCs_patient_reference_file-20"

  ltc_file_path <- fs::path(
    get_slf_dir(),
    ltc_dir,
    paste0(ltc_name, year)
  )
  ltc_file_path <- fs::path_ext_set(ltc_file_path, "zsav")

  return(haven::read_sav(ltc_file_path, ...))
}



#' Function for IT extract directory - stores IT extracts for all years
#'
#' @param type The type of extract, LTC, Deaths or year of PIS extract
#'
#' @return The file path to the requested extract
#' @export
#'
#' @examples
#' \dontrun{
#' it_extract_1819 <- readr::read_csv(file = read_it_extract_dir("1819"))
#' }
read_it_extract_dir <- function(type = c("LTCs", "Deaths", "1516", "1617", "1718", "1819", "1920", "2021", "2122")) {
  it_extract_dir <- "IT_extracts"

  extract_name <- dplyr::case_when(
    type == "LTCs" ~ "1_LTCs",
    type == "Deaths" ~ "2_Deaths",
    type == "1516" ~ "3_2015",
    type == "1617" ~ "4_2016",
    type == "1718" ~ "5_2017",
    type == "1819" ~ "6_2018",
    type == "1920" ~ "7_2019",
    type == "2021" ~ "8_2020",
    type == "2122" ~ "9_2021"
  )

  it_extract_file_path <- fs::path(
    get_slf_dir(),
    it_extract_dir,
    glue::glue("{it_extract_ref()}_extract_{extract_name}.csv.gz")
  )

  if (!fs::file_exists(it_extract_file_path)) {
    rlang::abort(message = glue::glue("The file {fs::path_file(it_extract_file_path)} does not exist"))
  }

  return(it_extract_file_path)
}
