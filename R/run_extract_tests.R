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
  process_homelessness_tests(data_list[["homelessness"]], year)
  process_mental_health_tests(data_list[["mental_health"]], year)
  process_maternity_tests(data_list[["maternity"]], year)
  process_ae_tests(data_list[["ae"]], year)
  process_acute_tests(data_list[["acute"]], year)

  return(run_extract_tests)
}
