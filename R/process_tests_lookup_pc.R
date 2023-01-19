#' Process pc Lookup tests
#'
#' @description This script takes the processed acute extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_lookup_pc <- function() {
  comparison <- produce_test_comparison(
    old_data = produce_slf_postcode_tests(readr::read_rds(get_slf_postcode_path(update = previous_update()))),
    new_data = produce_slf_postcode_tests(readr::read_rds(get_slf_postcode_path()))
  ) %>%
    write_tests_xlsx(sheet_name = "source_pc_lookup")

  return(comparison)
}
