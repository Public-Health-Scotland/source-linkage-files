#' Summarise flags for testing
#'
#' @param data the data should be in a format for summarising test flags
#'
#' @return a dataframe with a count of each flag
sum_test_flags <- function(data) {
  data <- data %>%
    dplyr::summarise_all(sum, na.rm = TRUE) %>%
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "measure",
      values_to = "value"
    ) %>%
    mutate(value = format(round(value, digits = 2), scientific = F))

  return(data)
}
