#' Test Comparison
#'
#' @description Produce a comparison test between the new processed data and the exisiting data
#'
#' @param old_data dataframe containing the old data test flags
#' @param new_data dataframe containing the new file data test flags
#'
#' @return a dataframe with a comparison of new and old data
#'
#' @family test functions
#' @seealso write_tests_xlsx
produce_test_comparison <- function(old_data, new_data) {
  dplyr::full_join(old_data,
    new_data,
    by = "measure",
    suffix = c("_old", "_new")
  ) %>%
    dplyr::mutate(
      diff = round(.data$value_new - .data$value_old, digits = 2),
      pct_change = scales::percent(.data$diff / .data$value_old),
      issue = !dplyr::between(.data$diff / .data$value_old, -.05, .05)
    )
}
