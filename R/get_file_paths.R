#' Get and check and full file path
#'
#' @description This generic function takes a directory and
#' file name then checks to make sure they exist.
#' The parameter `check_mode` will also test to make sure
#' the file is readable (default) or writeable (`check_mode = "write"`).
#' By default it will return an error if the file doesn't exist
#' but with `create = TRUE` it will create an empty file with
#' appropriate permissions.
#'
#' @param directory The file directory
#' @param file_name The file name (with extension if not supplied to `ext`)
#' @param ext The extension (type of the file) - optional
#' @param check_mode The mode passed to [fs::file_access], defaults to "read"
#' to check that you have read access to the file
#' @param create Optionally create the file if it doesn't exists
#'
#' @return The full file path, an error will be thrown
#' if the path doesn't exist or it's not readable
get_file_path <- function(directory, file_name, ext = NULL, check_mode = "read", create = FALSE) {
  if (!fs::dir_exists(directory)) {
    rlang::abort(message = glue::glue("The directory {directory} does not exist"))
  }

  file_path <- fs::path(directory, file_name)

  if (!is.null(ext)) {
    file_path <- fs::path_ext_set(file_path, ext)
  }

  if (!fs::file_exists(file_path)) {
    if (create == FALSE) {
      # The file doesn't exists and we don't want to create it
      rlang::abort(message = glue::glue("The file {fs::path_file(file_path)} does not exist in {directory}"))
    } else {
      # The file doesn't exist but we do want to create it
      fs::file_create(file_path, mode = "u=rw,g=rw")
      rlang::inform(message = glue::glue("The file {fs::path_file(file_path)} did not exist in {directory}, it has now been created as an empty file."))
    }
  }

  if (!fs::file_access(file_path, mode = check_mode)) {
    rlang::abort(message = glue::glue("The file {fs::path_file(file_path)} exists in {directory} but is not {check_mode}able"))
  }

  return(file_path)
}

#' General SLF directory for accessing HSCDIIP folders/files
#'
#' @return The path to the main SLF Extracts folder
#' @export
get_slf_dir <- function() {
  slf_dir <- fs::path("/conf/hscdiip/SLF_Extracts")

  return(slf_dir)
}

#' Get the Delayed Discharges file path
#'
#' @param ... additional arguments passed to `get_file_path`
#' @param dd_period The period to use for reading the file, defaults to `dd_period()`
#'
#' @return The path to the latest DD file
#' @export
get_dd_path <- function(..., dd_period = NULL) {
  if (is.null(dd_period)) {
    dd_period <- dd_period()
  }

  dd_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Delayed_Discharges"),
    file_name = paste0(dd_period, "DD_LinkageFile.zsav"),
    ...
  )

  return(dd_path)
}

#' Function for lookups directory - source postcode and gpprac lookup
#'
#' @param type the name of lookups within lookup directory
#' @param update the update month (latest or previous)
#'
#' @return The data as a tibble read using `haven::read_sav`
#' @export
read_lookups_dir <- function(type = c("postcode", "gpprac"), update = latest_update()) {
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


#' Get the path to the Practice Details file
#'
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return The practice details file
#' @export
get_practice_details_path <- function(...) {
  practice_details_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Lookups"),
    file_name = "Practice Details.sav",
    ...
  )

  return(practice_details_path)
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

#' Get the NSU file path for the given year
#'
#' @param year Year of extract
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the NSU file as an [fs::path]
#' @export
get_nsu_path <- function(year, ...) {
  nsu_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "NSU"),
    file_name = glue::glue("All_CHIs_20{year}.zsav"),
    ...
  )

  return(nsu_file_path)
}

#' Get the full path to the IT
#' Long Term Conditions extract
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the LTC extract as an [fs::path]
#' @export
get_it_ltc_path <- function(...) {
  it_ltc_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_extract_ref()}_extract_1_LTCs.csv.gz"),
    ...
  )

  return(it_ltc_path)
}

#' Get the full path to the IT Deaths extract
#'
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the IT Deaths extract as an [fs::path]
#' @export
get_it_deaths_path <- function(...) {
  it_deaths_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_extract_ref()}_extract_2_Deaths.csv.gz")
  )

  return(it_deaths_path)
}

#' Get the full path to the IT PIS extract
#'
#' @param year the year for the required extract
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the PIS extract as an [fs::path]
#' @export
get_it_prescribing_path <- function(year, ...) {
  extract_number <- switch(year,
    "1516" = "3_2015",
    "1617" = "4_2016",
    "1718" = "5_2017",
    "1819" = "6_2018",
    "1920" = "7_2019",
    "2021" = "8_2020",
    "2122" = "9_2021"
  )

  it_prescribing_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name = glue::glue("{it_extract_ref()}_extract_{extract_number}.csv.gz"),
    ...
  )

  return(it_prescribing_path)
}
