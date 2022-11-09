#' Demographic cohort lookup Path
#'
#' @description Get the path to the demographic cohort lookup, there is one
#' lookup per year.
#'
#' @param year financial year in '1718' format
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the demographic lookup as an [fs::path()]
#' @export
#' @family cohorts file path
#' @seealso [get_file_path()] for the generic function.
get_demographic_cohorts_path <- function(year, ...) {
  demographic_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = glue::glue("demographic_cohorts_{year}.rds"),
    ...
  )

  return(demographic_cohorts_path)
}

#' Service-use cohort lookup Path
#'
#' @description Get the path to the service-use cohort lookup, there is one
#' lookup per year.
#'
#' @param year financial year in '1718' format
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the service-use lookup as an [fs::path()]
#' @export
#' @family cohort lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_service_use_cohorts_path <- function(year, ...) {
  service_use_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = glue::glue("Service_Use_Cohorts_{year}.rds"),
    ...
  )

  return(service_use_cohorts_path)
}
