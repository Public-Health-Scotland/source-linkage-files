#' Run SLF extract tests
#'
#' @description This takes the processed data extracts and runs the equivalent
#' test on the data.
#'
#' @param year Year of extract
#' @param data_list List containing data for processed extracts.
#'
#' @return A list of data containing processed extracts.
#' @export
#'
run_extract_tests <- function(data_list, year) {
  process_tests_homelessness(data_list[["homelessness"]], year)
  process_tests_mental_health(data_list[["mental_health"]], year)
  process_tests_maternity(data_list[["maternity"]], year)
  process_tests_ae(data_list[["ae"]], year)
  process_tests_acute(data_list[["acute"]], year)

  return(run_extract_tests)
}
