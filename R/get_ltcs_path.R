#' Long Term Conditions File Path
#'
#' @description Get the full path to the LTC Reference File in this quarterly update
#'
#' @param ... additional arguments passed to [get_file_path()]
#' @param year financial year e.g. "1920"
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_ltcs_path <- function(year, update = latest_update(), ...) {
  ltcs_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "LTCs"),
    file_name = stringr::str_glue("anon-LTCs_patient_reference_file-20{year}_{update}.parquet"),
    ...
  )

  return(ltcs_file_path)
}
