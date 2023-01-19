#' Process Social Care Care Home episodes tests
#'
#' @description This script takes the processed demographic extract and produces
#' a test comparison with the previous data. This is written to disk as a CSV.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_sc_ch_episodes <- function() {
  comparison <- produce_test_comparison(
    old_data = produce_sc_ch_episodes_tests(
      readr::read_rds(get_sc_ch_episodes_path(update = previous_update()))
    ),
    new_data = produce_sc_ch_episodes_tests(
      readr::read_rds(get_sc_ch_episodes_path())
    )
  )

  comparison %>%
    write_tests_xlsx(sheet_name = "all_ch_episodes")

  return(comparison)
}
