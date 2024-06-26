#' Demographic cohorts lookup Path
#'
#' @description Get the path to the demographic cohorts lookup, there is one
#' lookup per year.
#'
#' @param year financial year in '1718' format
#' @param update The update to use
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the demographic cohorts lookup as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_demographic_cohorts_path <- function(year, update = latest_update(), ...) {
  demographic_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = stringr::str_glue(
      "anon-demographic_cohorts_{update}_{year}.parquet"
    ),
    ...
  )

  return(demographic_cohorts_path)
}

#' Service-use cohorts lookup Path
#'
#' @description Get the path to the service-use cohorts lookup, there is one
#' lookup per year.
#'
#' @inheritParams get_demographic_cohorts_path
#'
#' @return The path to the service-use cohorts lookup as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_service_use_cohorts_path <- function(year, update = latest_update(), ...) {
  service_use_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = stringr::str_glue(
      "anon-service_use_cohorts_{update}_{year}.parquet"
    ),
    ...
  )

  return(service_use_cohorts_path)
}
