################################################################################
# # Name of file -  00-update_refs.R
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - August 2021
# Update - Oct 2024
#
# Written/run on - RStudio Server
# Version of R - 4.1.2
#
# Description - Use this script to update references needed for the SLF update.
#
# Manual changes needed to the following Essential Functions:
#       # Check_year_valid
#       # Delayed_discharges_period
#       # Latest_update
#
################################################################################




#' Check data exists for a year
#'
#' @description  Check there is data available for a given year
#' as some extracts are year dependent. E.g Homelessness
#' is only available from 2016/17 onwards.
#'
#' @param year Financial year
#' @param type name of extract
#'
#' @return A logical TRUE/FALSE
check_year_valid <- function(
  year,
  type = c(
    "acute",
    "acute_cup",
    "ae",
    "ae_cup",
    "at",
    "ch",
    "client",
    "cmh",
    "cost_dna",
    "dd",
    "nrs_deaths",
    "dn",
    "gpooh",
    "hc",
    "homelessness",
    "hhg",
    "maternity",
    "mh",
    "nsu",
    "outpatients",
    "pis",
    "sds",
    "sparra"
  )
) {
  ## MANUALLY UPDATE ##
  # Check extracts which we do not have data for and ensure this is picked up
  # by the following code:
  # DN starts in 2015/16
  # SPARRA starts in 2015/16
  if (year <= "1415" && all(type %in% c("dn", "sparra"))) {
    return(FALSE)
    # CMH starts in 2016/17
    # Homelessness starts in 2016/17
    # DD starts in 2016/17
  } else if (year <= "1516" && all(type %in% c("cmh", "homelessness", "dd"))) {
    return(FALSE)
    # Social Care data sets start in 2017/18 Q4
    # Cost_DNAs start in 2017/18
  } else if (year <= "1617" && all(type %in% c("ch", "hc", "sds", "at", "client", "cost_dna"))) {
    return(FALSE)
    # HHG starts in 2018/19
  } else if (year <= "1718" && all(type %in% "hhg")) {
    return(FALSE)
    # CMH stops in 2020/21
    # DN stops in 2020/21
  } else if (year >= "2122" && all(type %in% c("cmh", "dn"))) {
    return(FALSE)
    # HHG stops in 2022/23
  } else if (year >= "2324" && all(type %in% "hhg")) {
    return(FALSE)
    ## CHECK - what is the latest NSU cohort available?
    # NSU is currently available for 2024/25
    ## CHECK - What period does SDS data get submitted?
    ## CHECK - what data do we have available for Social Care and SPARRA?
  } else if (year >= "2526" &&
    all(type %in% c("nsu", "sds", "at", "ch", "hc", "client"))) {
    return(FALSE)
  } else if (year >= "2627" &&
    all(type %in% c("sparra"))) {
    return(FALSE)
  }

  return(TRUE)
}

#-------------------------------------------------------------------------------

## AUTOMATED REFS - please check to ensure these are used correctly ##

#' End date
#'
#' @description
#' Returns the end date associated with the reporting period specified by the
#' `reporting_period` environment variable.
#'
#' @return A `Date` containing the end date of the latest reporting period.
#' @export
end_date <- function() {

  reporting_period <- Sys.getenv("reporting_period")

  if (!nzchar(reporting_period)) {
    stop("Environment variable `reporting_period` is not set.")
  }

  reporting_period_month <- stringr::str_extract(
    reporting_period,
    "[A-Za-z]+"
  )

  reporting_period_year <- stringr::str_extract(
    reporting_period,
    "\\d+"
  )

  reporting_period_end <- dplyr::case_when(
    reporting_period_month == "Jun" ~ paste0("30-06-", reporting_period_year),
    reporting_period_month == "Sep" ~ paste0("30-09-", reporting_period_year),
    reporting_period_month == "Dec" ~ paste0("31-12-", reporting_period_year),
    reporting_period_month == "Mar" ~ paste0("31-03-", reporting_period_year),
    TRUE ~ NA_character_
  )

  if (is.na(reporting_period_end)) {
    stop(
      "`reporting_period` must contain one of Mar, Jun, Sep or Dec. ",
      "Received: ", reporting_period
    )
  }

  lubridate::dmy(reporting_period_end)
}

#' Delayed Discharge period
#'
#' @description Get the period for Delayed Discharge
#'
#' @return The period for the Delayed Discharge file
#' as MMMYY_MMMYY
#' @export
#'
#' @family initialisation
get_dd_period <- function() {
  first_part <- substr(previous_update(), 1, 3)
  end_part <- substr(previous_update(), 7, 8)

  dd_period <- as.character(stringr::str_glue("Jul16_{first_part}{end_part}"))

  return(dd_period)
}


#' Latest update
#'
#' @description Get the date of the latest update, e.g 'Jun_2022'
#'
#' @return Latest update as MMM_YYYY
#' @export
#'
#' @family initialisation
latest_update <- function() {
  month <- as.character(lubridate::month(end_date(), label = TRUE))
  year <- as.character(lubridate::year(end_date()))
  latest_update <- as.character(stringr::str_glue("{month}_{year}"))

  return(latest_update)
}


#' Previous update
#'
#' @param months_ago Number of months since the previous update
#' the default is 3 i.e. one quarter ago.
#' @param override This allows specifying a specific update month if
#' required.
#'
#' @description Get the date of the previous update, e.g 'Mar_2022'
#'
#' @return previous update as MMM_YYYY
#' @export
#'
#' @family initialisation
#' @examples
#' previous_update() # Default 3 months
#' previous_update(1) # 1 month ago
#' previous_update(override = "May_2023") # Specific Month
previous_update <- function(months_ago = 3L, override = NULL) {
  if (!is.null(override)) {
    return(override)
  }

  latest_update_date <- lubridate::my(latest_update())

  previous_update_year <- lubridate::year(
    latest_update_date - lubridate::period(months_ago, "months")
  )

  previous_update_month <- lubridate::month(
    latest_update_date - lubridate::period(months_ago, "months"),
    label = TRUE,
    abbr = TRUE
  )

  previous_update <- stringr::str_glue(
    "{previous_update_month}_{previous_update_year}"
  )

  return(previous_update)
}


#' Extract latest FY from end_date
#'
#' @return fy in format "2024"
#' @export
#'
fy <- function() {
  # Latest FY
  fy <- phsmethods::extract_fin_year(end_date()) %>% substr(1, 4)

  return(fy)
}


#' Extract latest quarter from end_date
#'
#' @return qtr in format "Q1"
#' @export
#'
qtr <- function() {
  # Latest Quarter
  qtr <- lubridate::quarter(end_date(), fiscal_start = 4)

  qtr <- stringr::str_glue("Q{qtr}")

  return(qtr)
}


#' The year list for slf to update
#'
#' @description Get the vector of years to update slf
#'
#' @return The vector of financial years
#'
#' @export
#'
#' @family initialisation
years_to_run <- function() {

  years_to_run <- Sys.getenv("fys") %>%
    strsplit(",") %>%
    unlist()

  return(years_to_run)
}
