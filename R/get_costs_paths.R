#' Care Home Costs File Path
#'
#' @description Get the full Care Home costs lookup path
#'
#' @param ... additional arguments passed to [get_file_path()]
#' @param update passed through [latest_update()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_ch_costs_path <- function(..., update = NULL) {
  ch_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue(
      "Cost_CH_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.parquet"
    ),
    ...
  )

  return(ch_costs_path)
}

#' District Nursing Costs File Path
#'
#' @description Get the full District Nursing costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_costs_path <- function(..., update = NULL) {
  dn_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue(
      "Cost_DN_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.parquet"
    ),
    ...
  )

  return(dn_costs_path)
}

#' Raw District Nursing Costs File Path
#'
#' @description Get the District Nursing raw costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
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

#' GP Out of Hours Costs File Path
#'
#' @description Get the full GP Out of Hours costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_gp_ooh_costs_path <- function(..., update = NULL) {
  gp_ooh_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue(
      "Cost_GPOoH_Lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.parquet"
    ),
    ...
  )

  return(gp_ooh_costs_path)
}

#' Raw GP OoH Costs File Path
#'
#' @description Get the GP Out of Hours raw costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
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

#' Full Home Care Costs File Path
#'
#' @description Get the full Home Care costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_hc_costs_path <- function(..., update = NULL) {
  hc_costs_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue(
      "costs_hc_lookup{ifelse(is.null(update), '', paste0('_pre-', update))}.parquet"
    ),
    ...
  )

  return(hc_costs_path)
}

#' Raw Home Care Costs File Path
#'
#' @description Get the Home Care raw costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
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
