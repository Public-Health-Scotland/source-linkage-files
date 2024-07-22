#' Process Social Care, Care Home all episodes tests
#'
#' @param data The processed Care Home all episode data produced by
#' [process_extract_care_home()].
#'
#' @description This script takes the processed all Care Home file and produces
#' a test comparison with the previous data.
#'
#' @return a [tibble][tibble::tibble-package] containing a test comparison.
#'
#' @export
process_tests_sc_all_ch_episodes <- function(data) {
  data <- data %>%
    slfhelper::get_chi()

  comparison <- produce_test_comparison(
    old_data = produce_sc_all_episodes_tests(
      read_file(get_sc_ch_episodes_path(update = previous_update()))
    ),
    new_data = produce_sc_all_episodes_tests(
      data
    )
  )

  comparison %>%
    write_tests_xlsx(sheet_name = "all_ch_episodes", workbook_name = "lookup")

  return(comparison)
}
