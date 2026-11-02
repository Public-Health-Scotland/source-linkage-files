#' Raw District Nursing Costs File Path
#'
#' @description Get the raw District Nursing costs path
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the local raw costs lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_raw_costs_path <- function(...) {
  dn_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("DN_Costs.xlsx"),
    ...
  )
  return(dn_raw_costs_path)
}


#' District Nursing Contacts File Path
#'
#' @description Get the District Nursing contacts path
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the local contacts lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_contacts_path <- function(...) {
  dn_contacts_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("DN-Contacts-Numbers-for-Costs.csv"),
    ...
  )
  return(dn_contacts_path)
}


#' Raw GP OoH Costs File Path
#'
#' @description Get the GP Out of Hours raw costs path
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_gp_ooh_raw_costs_path <- function(...) {
  gp_ooh_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("OOH_Costs.xlsx"),
    ...
  )
  return(gp_ooh_raw_costs_path)
}


#' Raw Home Care Costs File Path
#'
#' @description Get the Home Care raw costs path
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_hc_raw_costs_path <- function(...) {
  hc_raw_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("hc_costs.xlsx"),
    ...
  )
  return(hc_raw_costs_path)
}
