#' Fix sc start dates
#'
#' @description Fix missing social care start dates.
#' Set this to the start of the fyear
#'
#' @param start_date A vector containing dates.
#' @param period Social care latest submission period.
#'
#' @return A date vector with replaced end dates
#' @export
fix_sc_start_dates <- function(start_date, period) {
  # Fix sds_start_date is missing by setting start_date to be the start of
  # financial year
  start_date <- dplyr::if_else(
    is.na(start_date),
    start_fy(year = substr(period, 1, 4), "alternate"),
    start_date
  )

  return(start_date)
}


#' Fix sc end dates
#'
#' @description Fix social care end dates when the end date is earlier than the
#' start date.
#' Set this to the end of the fyear
#'
#' @param start_date A vector containing dates.
#' @param end_date A vector containing dates.
#' @param period Social care latest submission period.
#'
#' @return A date vector with replaced end dates
#' @export
fix_sc_end_dates <- function(start_date, end_date, period) {
  # Fix sds_end_date is earlier than sds_start_date by setting end_date to be
  # the end of financial year
  end_date <- dplyr::if_else(
    start_date > end_date,
    end_fy(year = substr(period, 1, 4), "alternate"),
    end_date
  )

  return(end_date)
}
