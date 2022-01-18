#' Get the full Care Home costs lookup path
#'
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the costs lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_ch_costs_path <- function(...) {
  ch_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = glue::glue("Cost_CH_Lookup.sav"),
    ...
  )

  return(ch_costs_path)
}


#' Get the full District Nursing costs lookup path
#'
#' @param ... additional arguments passed to [get_file_path]
#'
#' @return The path to the costs lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_dn_costs_path <- function(...) {
  dn_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = glue::glue("Cost_DN_Lookup.sav"),
    ...
  )

  return(dn_costs_path)
}


#' Get the full GP Out of Hours costs lookup path
#'
#' @param ... additional arguments passed to \code{\link{get_file_path}}
#'
#' @return The path to the costs lookup as an \code{\link[fs]{path}}
#' @export
#' @family file path functions
#' @seealso \code{\link{get_file_path}} for the generic function.
get_gp_ooh_costs_path <- function(...) {
  gp_ooh_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = glue::glue("Cost_GPOoH_Lookup.sav"),
    ...
  )

  return(gp_ooh_costs_path)
}
