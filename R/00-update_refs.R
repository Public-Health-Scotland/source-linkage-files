#' Latest update
#'
#' @description Get the date of the latest update, e.g 'Jun_2022'
#'
#' @return Latest update as MMM_YYYY
#' @export
#'
#' @family initialisation
latest_update <- function() {
  "Sep_2022"
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
  "Jun_2022"
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
  "Jul16_Jun22"
}
