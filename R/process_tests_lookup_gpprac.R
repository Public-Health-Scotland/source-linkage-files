#' Process GP (gpprac) Lookup tests
#'
#' @description This script takes the processed gpprac lookup and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_lookup_gpprac <- function() {
  comparison <- produce_test_comparison(
    old_data = produce_slf_gpprac_tests(
      readr::read_rds(get_slf_gpprac_path(update = previous_update()))
    ),
    new_data = produce_slf_gpprac_tests(
      readr::read_rds(get_slf_gpprac_path())
    )
  ) %>%
    write_tests_xlsx(sheet_name = "source_gpprac_lookup")

  return(comparison)
}
