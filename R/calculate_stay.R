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
#' If there is no end date but sc_qtr is supplied then set this to the end of quarter.
#' If the quarter end date < start date and sc_qtr is supplied then set this to the end of next quarter.
#' @export
#'
#' @family date functions
calculate_stay <- function(year, start_date, end_date, sc_qtr = NULL) {
  # Normal calculation
  # if end_date is missing and sc_qtr is missing use dummy date
  if (missing(sc_qtr)) {
    # setup dummy date
    # if end date is missing then assign to end of the year
    dummy_discharge <- dplyr::if_else(
      is.na(end_date),
      end_fy(year) + lubridate::days(1),
      end_date
    )

    lubridate::time_length(lubridate::interval(start_date, dummy_discharge), unit = "days")
  } else {
    # Set Quarters
    qtr_end <- lubridate::add_with_rollback(lubridate::yq(sc_qtr), lubridate::period(6, "months"))
    next_qtr <- lubridate::add_with_rollback(lubridate::yq(sc_qtr), lubridate::period(9, "months"))

    dummy_end_date <- dplyr::case_when(
      # if end date is not missing use the end date
      !is.na(end_date) ~ end_date,
      # if end date is missing set to end of quarter
      qtr_end >= start_date ~ qtr_end,
      # if qtr_end < start_date then set to next qtr
      qtr_end < start_date ~ next_qtr
    )

    lubridate::time_length(lubridate::interval(start_date, dummy_end_date), unit = "days")
  }
}
