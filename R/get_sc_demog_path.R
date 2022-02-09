#' Get the Social Care Demographic lookup file path
#'
#' @param update The update month to use,
#' defaults to \code{\link{latest_update}}
#'
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the social care demographic file as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_sc_demog_lookup_path <- function(update = latest_update(), ...) {
  sc_demog_lookup_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care"),
    file_name = glue::glue("sc_demographics_lookup_{update}.zsav"),
    ...
  )

  return(sc_demog_lookup_path)
}
