#' Run SLF extract tests
#'
#' @param data_list
#' @param year
#'
#' @return
#' @export
#'
#' @examples
run_extract_tests <- function(data_list, year) {

  run_extract_tests <- list(
    run_homelessness_tests(data_list[[year]][['homelessness']], year),
    run_mental_health_tests(data_list[[year]][['homelessness']], year)
  )

  return(run_extract_tests)
}
