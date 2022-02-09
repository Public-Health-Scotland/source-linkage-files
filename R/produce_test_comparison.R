#' Produce a test comparison
#'
#' @param old_data dataframe containing the old data test flags
#' @param new_data dataframe containing the new file data test flags
#'
#' @return a dataframe with a comparison of new and old data
#' @family produce tests functions
produce_test_comparison <- function(old_data, new_data) {
  dplyr::full_join(old_data, new_data, by = "measure", suffix = c("_old", "_new")) %>%
    dplyr::mutate(
      diff = .data$value_new - .data$value_old,
      pct_change = .data$diff / .data$value_old * 100,
      issue = !dplyr::between(.data$pct_change, -5, 5)
    )
}
