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

  check_quarter_format(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(3, "months")
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

  check_quarter_format(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(6, "months")
  ) %>%
    lubridate::add_with_rollback(lubridate::period(-1, "days")) %>%
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

  check_quarter_format(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(6, "months")
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

  check_quarter_format(quarter)

  cal_quarter_date_unique <- lubridate::yq(quarter_unique)

  fy_quarter_date_unique <- lubridate::add_with_rollback(
    cal_quarter_date_unique,
    lubridate::period(9, "months")
  ) %>%
    lubridate::add_with_rollback(lubridate::period(-1, "days")) %>%
    purrr::set_names(quarter_unique)

  end_next_fy_quarter <- fy_quarter_date_unique[quarter] %>%
    unname()

  return(end_next_fy_quarter)
}

#' Check quarter format
#'
#' @inheritParams start_fy_quarter
#'
#' @return `quarter` invisibly if no issues were found
check_quarter_format <- function(quarter) {
  stopifnot(typeof(quarter) == "character")

  if (any(stringr::str_detect(quarter, "^\\d{4}Q[1-4]$", negate = TRUE), na.rm = TRUE)) {
    cli::cli_abort(c("{.var quarter} must be in the format {.val YYYYQx}
                   where {.val x} is the quarter number.",
      "v" = "For example {.val 2019Q1}."
    ))
  }

  return(invisible(quarter))
}
