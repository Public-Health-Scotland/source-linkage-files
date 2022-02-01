#' Compare test files
#'
#' @param old_data dataframe containing old file
#' @param new_data dataframe containing new file
#'
#' @return a dataframe with a comparison of new and old data
#' @importFrom dplyr mutate full_join
#' @family produce tests functions
produce_test_comparison <- function(old_data, new_data) {
  dplyr::full_join(old_data, new_data, by = "measure", suffix = c("_old", "_new")) %>%
    dplyr::mutate(
      diff = .data$value_new - .data$value_old,
      pctChange = .data$diff / .data$value_old * 100,
      issue = if_else(.data$pctChange >= 5, 1, 0)
    )
}
