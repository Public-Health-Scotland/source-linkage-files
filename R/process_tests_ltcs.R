#' Process LTCs tests
#'
#' @param year The year to process
#'
#' @description This script takes the processed LTCs extract and produces
#' a test comparison with the previous data. This is written to disk as a csv.
#'
#' @return a csv document containing tests
#' @export
#'
process_tests_ltcs <- function(year) {
  year <- check_year_format(year)

  new_data <- readr::read_rds(get_ltcs_path(year))

  # Find and flag any duplicate chis and chi/postcode combinations
  duplicates <- new_data %>%
    dplyr::summarise(
    duplicate_chi = nrow(new_data) - dplyr::n_distinct(.data$chi)
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
    write_tests_xlsx(sheet_name = "ltc")

  return(duplicates)
}
