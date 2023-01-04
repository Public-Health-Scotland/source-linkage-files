#' Process sc demographics tests
#'
#' @description This script takes the processed demographic extract and produces
#' a test comparison with the previous data. This is written to disk as a csv.
#'
#' @return a csv document containing tests
#' @export
#'
process_tests_sc_demographics <- function() {
  comparison <- produce_test_comparison(
    old_data = produce_sc_demog_lookup_tests(
      readr::read_rds(get_sc_demog_lookup_path(update = previous_update()))
    ),
    new_data = produce_sc_demog_lookup_tests(
      readr::read_rds(get_sc_demog_lookup_path())
    )
  ) %>%
    write_tests_xlsx(sheet_name = "sc_demographics")

  return(comparison)
}
