#' Check if a date, or interval is in the financial year
#'
#' @description Test to check if a date, or intervals is within a given
#' financial year.
#' If given just one date it will check to see if it is in the
#' given financial year.
#' When supplied with two dates it will check to see if
#' any part of that date range falls in the given financial year. If the
#' `date_end` is `NA` it checks that `date` was before or during the financial
#' year.
#'
#' @param fyyear The financial year in the format '1718' as a character
#' @param date The main/start date to check
#' @param date_end (optional) The end date
#'
#' @return a logical, TRUE/FALSE
#'
#' @export
#'
#' @examples
#' is_date_in_fyyear("2223", Sys.time())
#' is_date_in_fyyear(
#'   fyyear = "2122",
#'   date = as.Date("2020-01-01"),
#'   date_end = as.Date("2023-01-01")
#' )
#'
#' @family date functions
is_date_in_fyyear <- function(fyyear, date, date_end = NULL) {

  # Check that date is the correct type
  if (!inherits(date, c("Date", "POSIXct"))) {
    cli::cli_abort(c("{.var date} must be a `Date` or `POSIXct` vector",
      "x" = "You've supplied {?a/an} {.cls {class(date)}} vector"
    ))
  }

  if (!missing(date_end)) {
    # Check that date_end is the correct type
    if (!inherits(date_end, c("Date", "POSIXct"))) {
      cli::cli_abort(c("{.var date_end} must be a `Date` or `POSIXct` vector",
        "x" = "You've supplied {?a/an} {.cls {class(date_end)}} vector"
      ))
    }

    # Check that date_end always comes after date (or all date_end is NA)
    if (any(date > date_end, na.rm = TRUE) & !all(is.na(date_end))) {
      first_error <- which.min(date > date_end)

      cli::cli_abort(c("{.var date_end} must not be earlier than {.var date}",
        "i" = "See case {first_error} where
                         {.var date} = '{date[first_error]}'and
                         {.var date_end} = '{date_end[first_error]}'",
        "There {?is/are} {sum(date > date_end, na.rm = TRUE)} error{?s} in total."
      ))
    }
  }

  if (is.null(date_end)) {
    is_date_in_fyyear <- lubridate::`%within%`(date, fy_interval(fyyear))

    return(is_date_in_fyyear)
  } else {
    date_interval <- lubridate::interval(date, date_end)

    is_date_in_fyyear <- dplyr::if_else(!is.na(date_end),
      lubridate::int_overlaps(date_interval, fy_interval(fyyear)),
      (date <= end_fy(fyyear))
    )

    return(is_date_in_fyyear)
  }
}
