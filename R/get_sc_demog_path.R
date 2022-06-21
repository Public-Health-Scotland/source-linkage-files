#' Social Care Demographic Lookup
#'
#' @description Get the file path for the Social Care Demographic lookup file
#'
#' @param update The update month to use,
#' defaults to [latest_update()]
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the social care demographic file
#' as an [fs::path()]
#' @export
#' @family social care lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_sc_demog_lookup_path <- function(update = latest_update(), ...) {
  sc_demog_lookup_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care"),
    file_name = glue::glue("sc_demographics_lookup_{update}.rds"),
    ...
  )

  return(sc_demog_lookup_path)
}
