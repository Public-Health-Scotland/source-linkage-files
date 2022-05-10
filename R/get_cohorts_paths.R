#' Get the full path to the Demographics
#' Cohort lookup
#'
#' @param year The year for the cohorts extract
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the Demographics Cohort lookup
#' as a \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_demog_cohorts_path <- function(year, ...) {
  demog_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = glue::glue("Demographic_Cohorts_{year}.rds"),
    ...
  )

  return(demog_cohorts_path)
}

#' Get the full path to the Service Use
#' Cohort lookup
#'
#' @param year The year for the cohorts extract
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the Service Use Cohort lookup
#' as a \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_service_use_cohorts_path <- function(year, ...) {
  service_use_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = glue::glue("Service_Use_Cohorts_{year}.rds"),
    ...
  )

  return(service_use_cohorts_path)
}
