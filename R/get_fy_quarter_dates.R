#' Return the start of a quarter
#'
#' @description Get the start date of the specified financial year (FY) quarter.
#'
#' @param quarter usually `period` from Social Care, or any character vector
#' in the form `YYYYQX` where `X` is the quarter number
#'
#' @return a vector of dates of the start of the FY quarter
#' @export
#'
#' @examples
#' start_fy_quarter("2019Q1")
#'
#' @family date functions
start_fy_quarter <- function(quarter) {
  quarter_unique <- unique(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(3L, "months")
  ) %>%
    purrr::set_names(quarter_unique)

  start_fy_quarter <- fy_quarter_date_unique[quarter] %>%
    unname()

  return(start_fy_quarter)
}

#' Return the end of a quarter
#'
#' @description Get the end date of the specified FY quarter.
#'
#' @inheritParams start_fy_quarter
#'
#' @return a vector of dates of the end of the FY quarter
#' @export
#'
#' @examples
#' end_fy_quarter("2019Q1")
#'
#' @family date functions
end_fy_quarter <- function(quarter) {
  quarter_unique <- unique(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(6L, "months")
  ) %>%
    lubridate::add_with_rollback(lubridate::period(-1L, "days")) %>%
    purrr::set_names(quarter_unique)

  end_fy_quarter <- fy_quarter_date_unique[quarter] %>%
    unname()

  return(end_fy_quarter)
}

#' Return the start of the next quarter
#'
#' @description Get the start date of the following FY quarter.
#'
#' @inheritParams start_fy_quarter
#'
#' @return a vector of dates of the start of the next FY quarter
#' @export
#'
#' @examples
#' start_next_fy_quarter("2019Q1")
#'
#' @family date functions
start_next_fy_quarter <- function(quarter) {
  quarter_unique <- unique(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(6L, "months")
  ) %>%
    purrr::set_names(quarter_unique)

  start_next_fy_quarter <- fy_quarter_date_unique[quarter] %>%
    unname()

  return(start_next_fy_quarter)
}

#' Return the end of the next quarter
#'
#' @description Get the end date of the following FY quarter.
#'
#' @inheritParams start_fy_quarter
#'
#' @return a vector of dates of the end of the next FY quarter
#' @export
#'
#' @examples
#' end_next_fy_quarter("2019Q1")
#'
#' @family date functions
end_next_fy_quarter <- function(quarter) {
  quarter_unique <- unique(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(9L, "months")
  ) %>%
    lubridate::add_with_rollback(lubridate::period(-1L, "days")) %>%
    purrr::set_names(quarter_unique)

  end_next_fy_quarter <- fy_quarter_date_unique[quarter] %>%
    unname()

  return(end_next_fy_quarter)
}
