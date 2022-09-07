#' Title
#'
#' @param years_to_run
#'
#' @return
#' @export
#'
#' @examples
run_phase_1_processing <- function(select_years_to_run){

extract_data <- purrr::map(
  years_to_run,
  process_data_extracts
)

extract_tests <- purrr::map(
  years_to_run,
  run_extract_tests
)

}
