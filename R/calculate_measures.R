#' Calculate Measures for Testing
#'
#' @description Produces measures used within testing extracts.
#' Computes various measures for the variables specified.
#'
#' @param data A processed dataframe containing a
#' summary of the mean and sum of variables.
#'
#' @param vars Specify variables you want to test.
#' This will match this e.g c(`beddays`, `cost`, `yearstay`).
#' Default as NULL for summarising everything.
#'
#' @param measure The measure you want to apply to variables
#'
#' @param group_by Default as NULL for grouping variables. Specify
#' variables for grouping e.g recid for episode file testing.
#'
#' @return a tibble with a summary
#'
#' @family extract test functions
#' @seealso produce_source_extract_tests
calculate_measures <- function(
    data,
    vars = NULL,
    measure = c("sum", "all", "min-max"),
    group_by = NULL) {
  measure <- match.arg(measure)

  if (!is.null(group_by)) {
    group_by <- match.arg(group_by, "recid")

    if (group_by == "recid") {
      data <- data %>%
        dplyr::group_by(.data$recid)
    }
  }


  if (measure == "all") {
    data <- data %>%
      dplyr::select(tidyselect::contains({{ vars }})) %>%
      dplyr::summarise(
        dplyr::across(
          dplyr::everything(),
          list(
            "total" = ~ sum(.x, na.rm = TRUE),
            "mean" = ~ mean(.x, na.rm = TRUE),
            "median" = ~ median(.x, na.rm = TRUE)
          ),
          .names = "{.fn}_{.col}"
        )
      )
  } else if (measure == "sum") {
    data <- data %>%
      dplyr::summarise(
        dplyr::across(
          tidyselect::everything(),
          ~ sum(.x, na.rm = TRUE)
        )
      )
  } else if (measure == "min-max") {
    data <- data %>%
      dplyr::select(tidyselect::contains({{ vars }})) %>%
      dplyr::mutate(
        dplyr::across(
          dplyr::where(lubridate::is.Date),
          ~ convert_date_to_numeric(.x)
        )
      ) %>%
      dplyr::summarise(
        dplyr::across(
          tidyselect::everything(),
          list(
            "min" = ~ min(.x, na.rm = TRUE),
            "max" = ~ max(.x, na.rm = TRUE)
          ),
          .names = "{.fn}_{.col}"
        )
      )
  }

  if (!is.null(group_by)) {
    if (group_by == "recid") {
      pivot_data <- data %>%
        tidyr::pivot_longer(
          cols = !.data$recid,
          names_to = "measure",
          values_to = "value"
        )
    }
  } else {
    pivot_data <- data %>%
      tidyr::pivot_longer(
        cols = dplyr::everything(),
        names_to = "measure",
        values_to = "value"
      )
  }

  return(pivot_data)
}
