#' Run SLF extract tests
#'
#' @description This takes the processed data extracts and runs the equivalent
#' test on the data.
#'
#' @param year Year of extract
#'
#' @return A list of data containing processed extracts.
#' @export
#'
run_extract_tests <- function(year) {
  process_homelessness_tests(extract_data[[year]][["homelessness"]], year)
  process_mental_health_tests(extract_data[[year]][["mental_health"]], year)

  return(run_extract_tests)
}
