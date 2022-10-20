#' Create Monthly Beddays
#'
#' @description Generate counts of beddays per month for an episode
#' with an admission and discharge date
#'
#' @param data Data to calculate beddays for.
#' @param year The financial year in '1718' format.
#' @param admission_date The admission/start date variable.
#' @param discharge_date The admission/start date variable
#' @param count_last (default `TRUE`) - Should the last day be counted,
#' instead of the first?
#'
#' @return a [tibble][tibble::tibble-package] with additional variables `apr_beddays` to `mar_beddays`
#' that count the beddays which occurred in the month.
#'
#' @export
#'
#' @seealso create_monthly_costs
create_monthly_beddays <- function(data, year, admission_date, discharge_date, count_last = TRUE) {

  # Extract date vectors for checking
  admission_dates_vector <- dplyr::pull(data, {{ admission_date }})
  discharge_dates_vector <- dplyr::pull(data, {{ discharge_date }})

  # Check that dates are the correct types
  if (!inherits(admission_dates_vector, c("Date", "POSIXct"))) {
    cli::cli_abort(c("{.var admission_date} must be a `Date` or `POSIXct` vector",
      "x" = "You've supplied {?a/an} {.cls {class(admission_dates_vector)}} vector"
    ))
  }
  if (!inherits(discharge_dates_vector, c("Date", "POSIXct"))) {
    cli::cli_abort(c("{.var discharge_date} must be a `Date` or `POSIXct` vector",
      "x" = "You've supplied {?a/an} {.cls {class(discharge_dates_vector)}} vector"
    ))
  }

  # Check that discharge_date always comes after admission_date (or all discharge_dates_vector is NA)
  if (any(admission_dates_vector > discharge_dates_vector, na.rm = TRUE) & !all(is.na(discharge_dates_vector))) {
    first_error <- which.max(admission_dates_vector > discharge_dates_vector)

    cli::cli_abort(c("{.var discharge_date} must not be earlier than
                       {.var admission_date}",
      "i" = "See case {first_error} where
         {.var admission_date} = '{admission_dates_vector[first_error]}' and
         {.var discharge_date} = '{discharge_dates_vector[first_error]}'",
      "There {?is/are} {sum(admission_dates_vector > discharge_dates_vector, na.rm = TRUE)}
        error{?s} in total."
    ))
  }


  # Create a 'stay interval' from the episode dates
  data <- data %>%
    dplyr::mutate(stay_interval = lubridate::interval(
      {{ admission_date }},
      # If discharge date is NA then calculate beddays to the end of the year
      dplyr::if_else(is.na({{ discharge_date }}),
        end_fy(year) + lubridate::days(1),
        {{ discharge_date }}
      )
    ) %>%
      # Shift it forward by a day (default)
      # so we will count the last day and not the first.
      lubridate::int_shift(by = lubridate::days(ifelse(count_last, 1, 0))))

  # Create the start dates of the months for the financial year
  cal_year <- as.numeric(convert_fyyear_to_year(year))
  month_start <- c(
    lubridate::my(paste0(
      month.abb[4:12],
      cal_year
    )),
    lubridate::my(paste0(
      month.abb[1:3],
      cal_year + 1
    ))
  )

  # Turn the start dates into 1 month intervals
  month_intervals <- lubridate::interval(
    month_start,
    month_start + months(1)
  ) %>%
    # Name the intervals for use later
    rlang::set_names(paste0(tolower(month.abb[c(4:12, 1:3)]), "_beddays"))

  # Work out the beddays for each month
  beddays <- purrr::map_dfc(
    month_intervals,
    ~ lubridate::intersect(data$stay_interval, .x) %>%
      lubridate::time_length(unit = "days") %>%
      # Replace any NAs with zero
      tidyr::replace_na(0) %>%
      as.integer()
  )

  # Join the beddays back to the data
  data <- dplyr::bind_cols(data, beddays) %>%
    dplyr::select(-"stay_interval")

  return(data)
}
