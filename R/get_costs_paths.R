#' Get the full Care Home costs lookup path
#'
#' @param ... additional arguments passed to [get_file_path()]
#' @param update passed through [latest_update()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_ch_costs_path <- function(..., update = NULL) {
  ch_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = glue::glue("Cost_CH_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.rds"),
    ...
  )

  return(ch_costs_path)
}

#' Get the full District Nursing costs lookup path
#'
#' @param ... additional arguments passed to  [get_file_path()]
#' @param update passed through [latest_update()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_dn_costs_path <- function(..., update = NULL) {
  dn_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = glue::glue("Cost_DN_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.rds"),
    ...
  )

  return(dn_costs_path)
}


#' Get the full GP Out of Hours costs lookup path
#'
#' @param ... additional arguments passed to [get_file_path()]
#' @param update passed through [latest_update()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_gp_ooh_costs_path <- function(..., update = NULL) {
  gp_ooh_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = glue::glue("Cost_GPOoH_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.rds"),
    ...
  )

  return(gp_ooh_costs_path)
}
