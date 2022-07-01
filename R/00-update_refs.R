#' Get the IT extract ref number
#'
#' @return the IT extract ref number
#' @export
#'
#' @family initialisation
it_extract_ref <- function() {
  "SCTASK0270905"
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
  "Mar_2022"
}

#' Previous update
#'
#' @description Get the date of the previous update, e.g 'Mar_2022'
#'
#' @return previous update as MMM_YYYY
#' @export
#'
#' @family initialisation
previous_update <- function() {
  "Dec_2021"
}

#' Delayed Discharge period
#'
#' @description Get the period for Deyalyed Discharge
#'
#' @return The period for the Delayed Discharge file
#' as MMMYY_MMMYY
#' @export
#'
#' @family initialisation
get_dd_period <- function() {
  "Jul16_Dec21"
}
