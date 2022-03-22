#' Calculate measures for testing
#'
#' @param data A processed dataframe containing cost_total_net and monthly costs
#'
#' @return a tibble with the total sum of costs
#' @export
calculate_measures <- function(data, type = c("cost", "beddays", "yearstay")) {
  data %>%
    summarise(
      across(matches(type), ~ sum(.x, na.rm = TRUE), .names = "total_{col}"),
      across(matches(type), ~ mean(.x, na.rm = TRUE), .names = "mean_{col}")
    )
  tidyr::pivot_longer(
    cols = tidyselect::everything(),
    names_to = "measure",
    values_to = "value"
  )
}


