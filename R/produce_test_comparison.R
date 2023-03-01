#' Test Comparison
#'
#' @description Produce a comparison test between the new processed data
#' and the existing data
#'
#' @param old_data dataframe containing the old data test flags
#' @param new_data dataframe containing the new file data test flags
#' @param recid Logical True/False. Use True when comparing the ep file.
#'
#' @return a dataframe with a comparison of new and old data
#'
#' @export
#'
#' @family test functions
#' @seealso write_tests_xlsx
produce_test_comparison <- function(old_data, new_data, recid = FALSE) {
  if (recid) {
    dplyr::full_join(old_data,
      new_data,
      by = c("recid", "measure"),
      suffix = c("_old", "_new")
    ) %>%
      dplyr::mutate(
        difference = round(.data$value_new - .data$value_old, digits = 2L),
        pct_change = scales::percent(.data$difference / .data$value_old),
        issue = !dplyr::between(.data$difference / .data$value_old, -0.05, 0.05)
      )
  } else {
    dplyr::full_join(old_data,
      new_data,
      by = "measure",
      suffix = c("_old", "_new")
    ) %>%
      dplyr::mutate(
        difference = round(.data$value_new - .data$value_old, digits = 2L),
        pct_change = scales::percent(.data$difference / .data$value_old),
        issue = !dplyr::between(.data$difference / .data$value_old, -0.05, 0.05)
      )
  }

}
