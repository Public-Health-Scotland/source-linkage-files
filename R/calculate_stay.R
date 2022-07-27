#' Calculate total length of stay
#'
#' @description Calculate the total length of stay between start_date and end_date.
#' If the end_date is missing then use the dummy discharge date.
#'
#' @param data Data to calculate the total length of stay
#' @param year The financial year in '1920' format
#' @param start_date The admission/start date variable. e.g. record_keydate1
#' @param end_date The discharge/end date variable. e.g record_keydate2
#'
#' @return a [tibble][tibble::tibble-package] with additional variable `stay`.
#' If there is no end date use dummy discharge to calculate the total length of stay.
#' @export
#'
#' @family date functions
calculate_stay <- function(year, start_date, end_date, sc_qtr = NULL) {
  lubridate::time_length(lubridate::interval(start_date, end_date), unit = "days")

  if (is.na(end_date) & is.null(sc_qtr)) {

    dummy_discharge <- dplyr::if_else(
      is.na(end_date),
      end_fy(year) + days(1),
      end_date
    )

    lubridate::time_length(lubridate::interval(start_date, dummy_discharge), unit = "days")
  } else if (is.na(end_date) & !is.null(sc_qtr)) {

    qtr_end <- yq(sc_qtr) %m+% period(6, "months") %m-% days(1)

    lubridate::time_length(lubridate::interval(start_date, qtr_end), unit = "days")
  }
}
