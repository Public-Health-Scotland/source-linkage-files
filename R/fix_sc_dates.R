#' Fix sc start dates
#'
#' @description Fix missing social care start dates.
#' Set this to the start of the fyear
#'
#' @param start_date A vector containing dates.
#' @param period_start the beginning date of Social care latest submission period.
#'
#' @return A date vector with replaced end dates
fix_sc_start_dates <- function(start_date, period_start) {
  # Fix sds_start_date is missing by setting start_date to be the start of
  # financial period
  start_date <- dplyr::if_else(
    is.na(start_date),
    period_start,
    start_date
  )

  return(start_date)
}


#' Fix sc end dates
#'
#' @description Fix social care end dates when the end date is earlier than the
#' start date. Set this to the end of the fyear
#'
#' @param start_date A vector containing dates.
#' @param end_date A vector containing dates.
#' @param period_end_date the last date of Social care latest submission period.
#'
#' @return A date vector with replaced end dates
fix_sc_end_dates <- function(start_date, end_date, period_end_date) {
  # Fix sds_end_date is earlier than sds_start_date by setting end_date to be
  # the end of financial year
  end_date <- dplyr::if_else(
    start_date > end_date,
    period_end_date,
    end_date
  )

  return(end_date)
}




#' Fix sc missing end dates
#'
#' @description Fix social care end dates when the end date is earlier than the
#' start date. Set this to the end of the fyear
#'
#' @param end_date A vector containing dates.
#' @param period_end the last date of Social care latest submission period.
#'
#' @return A date vector with replaced end dates
fix_sc_missing_end_dates <- function(end_date, period_end) {
  # Fix sds_end_date is earlier than sds_start_date by setting end_date to be
  # the end of financial period
  end_date <- dplyr::if_else(
    is.na(end_date),
    period_end,
    end_date
  )

  return(end_date)
}
