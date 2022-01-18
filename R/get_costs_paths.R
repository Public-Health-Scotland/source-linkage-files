#' Get the full Care Home costs lookup path
#'
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the costs lookup as an [fs::path]
#' @export
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
#' @return the path to the costs lookup as an [fs::path]
#' @export
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
#' @param ... additional arguments passed to `get_file_path`
#'
#' @return the path to the costs lookup as an [fs::path]
#' @export
get_gp_ooh_costs_path <- function(...) {
  gp_ooh_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = glue::glue("Cost_GPOoH_Lookup.sav"),
    ...
  )

  return(gp_ooh_costs_path)
}
