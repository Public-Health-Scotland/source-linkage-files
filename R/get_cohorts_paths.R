#' Get the full path to the Demographics
#' Cohort lookup
#'
#' @param year The year for the cohorts extract
#' @param ... additional arguments passed to [get_file_path]
#'
#' @return the path to the Demographics Cohort lookup as an [fs::path]
#' @export
get_demog_cohorts_path <- function(year, ...) {
  demog_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = glue::glue("Service_Use_Cohorts_{year}.zsav"),
    ...
  )

  return(demog_cohorts_path)
}


#' Get the full path to the Service Use
#' Cohort lookup
#'
#' @param year The year for the cohorts extract
#' @param ... additional arguments passed to [get_file_path]
#'
#' @return the path to the Service Use Cohort lookup as an [fs::path]
#' @export
get_service_use_cohorts_path <- function(year, ...) {
  service_use_cohorts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Cohorts"),
    file_name = glue::glue("Demographic_Cohorts_{year}.zsav"),
    ...
  )

  return(service_use_cohorts_path)
}
