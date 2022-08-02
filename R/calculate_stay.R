#' Calculate total length of stay
#'
#' @description Calculate the total length of stay between start_date and end_date.
#' If the end_date is missing then use the dummy discharge date.
#'
#' @param year The financial year in '1920' format
#' @param start_date The admission/start date variable. e.g. record_keydate1
#' @param end_date The discharge/end date variable. e.g record_keydate2
#' @param sc_qtr The latest submitted quarter. e.g. sc_latest_submission
#'
#' @return a [tibble][tibble::tibble-package] with additional variable `stay`.
#' If there is no end date use dummy discharge to calculate the total length of stay.
#' @export
#'
#' @family date functions
calculate_stay <- function(year, start_date, end_date, sc_qtr = NULL) {

  # Set Quarters
  qtr_end <- yq(sc_qtr) %m+% period(6, "months")
  next_qtr <- yq(sc_qtr) %m+% period(9, "months")

  if (is.missing(sc_qtr)) {
    # Do normal stay calculation
    dummy_discharge <- dplyr::if_else(
      is.na(end_date),
      end_fy(year) + days(1),
      end_date
    )

    lubridate::time_length(lubridate::interval(start_date, dummy_discharge), unit = "days")
  } else {
    # Do SC stay calculation and set to end of quarter
    lubridate::time_length(lubridate::interval(start_date, qtr_end), unit = "days")
  }
  # Do SC calculation if qtr_end < start_date then set to next qtr
  if (qtr_end < start_date) {
    lubridate::time_length(lubridate::interval(start_date, next_qtr), unit = "days")
  }
}
