#' Run SLF extract tests
#'
#' @param data_list
#' @param year
#'
#' @return
#' @export
#'
#' @examples
run_extract_tests <- function(year) {

    run_homelessness_tests(extract_data[[year]][["homelessness"]], year)
    run_mental_health_tests(extract_data[[year]][["mental_health"]], year)


  return(run_extract_tests)
}
