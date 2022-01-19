#' Summarise flags for testing
#'
#' @param data the data should be in a format for summarising
#'
#' @return a dataframe with a count of each flag
#' @importFrom dplyr across
sum_test_flags <- function(data){

  data <- data %>%
    dplyr::summarise(across(tidyselect::vars_select_helpers$where(.data$is.numeric), sum, na.rm = TRUE)) %>%
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "measure",
      values_to = "value"
    )
}
