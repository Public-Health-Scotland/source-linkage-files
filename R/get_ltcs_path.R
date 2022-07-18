#' Long Term Conditions File Path
#'
#' @description Get the full path to the LTC Reference File
#'
#' @param ... additional arguments passed to [get_file_path()]
#' @param year financial year e.g. "1920"
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_ltcs_path <- function(year, ...) {
  ltcs_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "LTCs"),
    file_name = glue::glue("LTC_patient_reference_file-20{year}.rds"),
    ...
  )

  return(ltcs_file_path)
}
