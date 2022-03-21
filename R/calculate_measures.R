#' Calculate measures for testing
#'
#' @param data A processed dataframe containing cost_total_net and monthly costs
#'
#' @return a tibble with the total sum of costs
#' @export
calculate_measures <- function(data, type = c("cost", "beddays", "yearstay"), measure = c(sum, mean), name = c("_total", "_mean")) {
  data %>%
    summarise(across(contains(type), ~ measure(.x, na.rm = TRUE), .names = "{col}_{.fn}")) %>%
    rename_at(vars(matches(type)), ~ paste0(., {{name}})) %>%
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "measure",
      values_to = "value"
    )
}
