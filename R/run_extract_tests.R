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
run_extract_tests <- function(data_list, year) {
  process_homelessness_tests(data_list[["homelessness"]], year)
  process_mental_health_tests(data_list[["mental_health"]], year)
  process_maternity_tests(data_list[["maternity"]], year)

  return(run_extract_tests)
}
