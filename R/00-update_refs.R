#' Latest update
#'
#' @description Get the date of the latest update, e.g 'Jun_2022'
#'
#' @return Latest update as MMM_YYYY
#' @export
#'
#' @family initialisation
latest_update <- function() {
  "Sep_2024"
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
  "Jul16_Jun24"
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
