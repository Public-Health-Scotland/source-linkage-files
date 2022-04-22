#' Calculate measures for testing
#'
#' @param data A processed dataframe containing a summary of the mean and sum of variables
#' @param vars Specify variables you want to test.
#' This will 'match' this e.g c("beddays", "cost", "yearstay). Default as NULL for summarising
#' everything in a dataframe.
#' @param measure The measure you want to apply to variables
#'
#' @return a tibble with a summary
#' @export
#'
calculate_measures <- function(data, vars = NULL, measure = c("sum", "all", "min-max")) {
  measure <- match.arg(measure)

  if (measure == "all") {
    data <- data %>%
      dplyr::select(tidyselect::matches({{ vars }})) %>%
      dplyr::summarise(
        dplyr::across(tidyselect::everything(), ~ sum(.x, na.rm = TRUE), .names = "total_{col}"),
        dplyr::across(tidyselect::everything(vars = !tidyselect::starts_with("total_")), ~ mean(.x, na.rm = TRUE), .names = "mean_{col}")
      )
  } else if (measure == "sum") {
    data <- data %>%
      dplyr::summarise(dplyr::across(tidyselect::everything(), ~ sum(.x, na.rm = TRUE)))
  } else if (measure == "min-max") {
    data <- data %>%
      dplyr::select(tidyselect::matches({{ vars }})) %>%
      dplyr::summarise(
        dplyr::across(tidyselect::everything(), ~ min(.x, na.rm = TRUE), .names = "min_{col}"),
        dplyr::across(tidyselect::everything(vars = !tidyselect::starts_with("min_")), ~ max(.x, na.rm = TRUE), .names = "max_{col}")
      ) %>%
      dplyr::mutate(dplyr::across(tidyselect::everything(), ~ as.numeric(.x)))
  }

  pivot_data <- data %>%
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "measure",
      values_to = "value"
    )

  return(pivot_data)
}
