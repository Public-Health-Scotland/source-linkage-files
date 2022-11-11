#' Fix sc end dates
#'
#' @description Fix social care end dates when the end date is earlier than the start date.
#' Set this to the end of the fyear
#'
#' @param start_date A vector containing dates.
#' @param end_date A vector containing dates.  The dummy code to use. Default is 9995
#'
#'
#' @return A date vector with replaced end dates
#' @export
fix_sc_end_dates <- function(start_date, end_date, period) {
  # Fix sds_end_date is earlier than sds_start_date by setting end_date to be the end of fyear
  end_date <- dplyr::if_else(
    start_date > end_date,
    end_fy(year = substr(period, 1, 4), "alternate"),
    end_date
  )

  return(end_date)
}
