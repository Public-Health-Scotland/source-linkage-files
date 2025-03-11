#' Process LTCs tests
#'
#' @description This script takes the processed LTCs extract and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_ltcs <- function(data, year) {
  # Find and flag any duplicate chis and chi/postcode combinations
  duplicates <- data %>%
    slfhelper::get_chi() %>%
    dplyr::summarise(
      duplicate_chi = nrow(data) - dplyr::n_distinct(.data$chi)
    ) %>%
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "measure",
      values_to = "value"
    ) %>%
    dplyr::mutate(
      difference = NA,
      pct_change = NA,
      issue = NA
    ) %>%
    # Save test comparisons as an excel workbook
    write_tests_xlsx(sheet_name = "ltc", year = year, workbook_name = "extract")

  return(duplicates)
}
