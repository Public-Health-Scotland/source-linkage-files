#' Calculate measures for testing
#'
#' @param data A processed dataframe containing a summary of the mean and sum of variables
#' @param vars Specify variables you want to test.
#' This will 'match' this e.g c("beddays", "cost", "yearstay)
#'
#' @return a tibble with a summary
#' @export
#'
calculate_measures <- function(data, vars, measure = c("sum", "all")) {
  data <- select(data, matches({{ vars }}))

  if (measure == "all") {
    data <- data %>%
      summarise(
        across(everything(), ~ sum(.x, na.rm = TRUE), .names = "total_{col}"),
        across(everything(vars = !starts_with("total_")), ~ mean(.x, na.rm = TRUE), .names = "mean_{col}")
      )
  } else if (measure == "sum") {
    data <- data %>%
      summarise(across(everything(), ~ sum(.x, na.rm = TRUE), .names = "total_{col}"))
  }


  data <- data %>%
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "measure",
      values_to = "value"
    ) %>%
    mutate(value = format(round(value, digits = 2), scientific = F))

  return(data)
}
