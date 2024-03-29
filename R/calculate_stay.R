#' Calculate total length of stay
#'
#' @description Calculate the total length of stay between `start_date` and
#' `end_date`.
#' If the `end_date` is missing then use the dummy discharge date.
#'
#' @param year The financial year in '1920' format
#' @param start_date The admission/start date variable. e.g. `record_keydate1`
#' @param end_date The discharge/end date variable. e.g. `record_keydate2`
#' @param sc_qtr The latest submitted quarter. e.g. `sc_latest_submission`
#'
#' @return a [tibble][tibble::tibble-package] with additional variable `stay`.
#' If there is no end date use dummy discharge to calculate the total
#' length of stay.
#' If there is no end date but sc_qtr is supplied then set this to the end of
#' the quarter.
#' If quarter `end_date < start_date` and `sc_qtr` is supplied then set this
#' to the end of the next quarter.
#' @family date functions
calculate_stay <- function(year, start_date, end_date, sc_qtr = NULL) {
  # Normal calculation
  # If end_date is missing and sc_qtr is missing use dummy date
  if (missing(sc_qtr)) {
    # Setup dummy date
    # If end_date is missing then assign to end of the year
    dummy_discharge <- dplyr::if_else(
      is.na(end_date),
      end_fy(year) + lubridate::days(1L),
      end_date
    )

    lubridate::time_length(lubridate::interval(start_date, dummy_discharge),
      unit = "days"
    )
  } else {
    # Check the quarters
    if (anyNA(sc_qtr)) {
      cli::cli_abort("Some of the submitted quarters are missing")
    }

    # Set Quarters
    qtr_end <- lubridate::add_with_rollback(
      end_fy_quarter(sc_qtr),
      lubridate::period(1L, "days")
    )
    next_qtr <- lubridate::add_with_rollback(
      end_next_fy_quarter(sc_qtr),
      lubridate::period(1L, "days")
    )

    # check logic here for care home methodology
    dummy_end_date <- dplyr::case_when(
      # If end_date is not missing use the end date
      !is.na(end_date) ~ end_date,
      # If end_date is missing set to end of quarter
      qtr_end >= start_date ~ qtr_end,
      # If qtr_end < start_date then set to next quarter
      qtr_end < start_date ~ next_qtr
    )

    lubridate::time_length(lubridate::interval(start_date, dummy_end_date),
      unit = "days"
    )
  }
}
