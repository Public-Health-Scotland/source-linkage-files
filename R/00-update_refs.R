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
#       # End_date
#       # Check_year_valid
#       # Delayed_discharges_period
#       # Latest_update
#
################################################################################

## MANUALLY UPDATE ##-----------------------------------------------------------

#' End date
#'
#' @return Get the end date of the latest update period
#' @export
#'
end_date <- function() {
  ## MANUALLY UPDATE ##
  # Specify update by indicating end of quarter date
  # Q1 June = 30062024
  # Q2 September = 30092024
  # Q3 December = 31122024
  # Q4 March = 31032025
  end_date <- lubridate::dmy(31032025)

  return(end_date)
}


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
      "ae",
      "at",
      "ch",
      "client",
      "cmh",
      "cost_dna",
      "dd",
      "deaths",
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
    )) {
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
    # NSU is currently available for 2023/24
    ## CHECK - What period does SDS data get submitted?
    # SDS is only available up to March 2024 currently.
  } else if (year >= "2425" && all(type %in% c("nsu", "sds"))) {
    return(FALSE)
    ## CHECK - what data do we have available for Social Care and SPARRA?
  } else if (year >= "2526" && all(type %in% c("ch", "hc", "sds", "at", "sparra"))) {
    return(FALSE)
  }

  return(TRUE)
}

#-------------------------------------------------------------------------------

## AUTOMATED REFS - please check to ensure these are used correctly ##

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
  fy_start_2digit <- 17
  fy_end_2digit <- 24
  years_to_run <- paste0(
    fy_start_2digit:fy_end_2digit,
    (fy_start_2digit + 1):(fy_end_2digit + 1)
  )
  return(years_to_run)
}
