#' Care Home Costs File Path
#'
#' @description Get the Care Home costs lookup path
#'
#' @param BYOC_MODE BYOC_MODE
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_ch_costs_path <- function(BYOC_MODE, ...) {
  if (isTRUE(BYOC_MODE)) {
    ch_costs_path <- file.path(
      denodo_output_path(), "cost_ch_lookup.parquet"
    )
  } else {
    ch_costs_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Costs"),
      file_name = stringr::str_glue(
        "cost_ch_lookup.parquet"
      ),
      ...
    )
  }

  return(ch_costs_path)
}


#' District Nursing Costs File Path
#'
#' @description Get the District Nursing costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the processed costs lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_costs_path <- function(BYOC_MODE, ...) {
  if (isTRUE(BYOC_MODE)) {
    dn_costs_path <- file.path(
      denodo_output_path(), "cost_dn_lookup.parquet"
    )
  } else {
    dn_costs_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Costs"),
      file_name = stringr::str_glue(
        "Cost_DN_Lookup.parquet"
      ),
      ...
    )
  }

  return(dn_costs_path)
}


#' GP Out of Hours Costs File Path
#'
#' @description Get the GP Out of Hours costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_gp_ooh_costs_path <- function(BYOC_MODE, ...) {
  if (isTRUE(BYOC_MODE)) {
    gp_ooh_costs_path <- file.path(
      denodo_output_path(), "cost_gpooh_lookup.parquet"
    )
  } else {
    gp_ooh_costs_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Costs"),
      file_name = stringr::str_glue(
        "cost_gpooh_lookup.parquet"
      ),
      ...
    )
  }

  return(gp_ooh_costs_path)
}


#' Home Care Costs File Path
#'
#' @description Get the Home Care costs lookup path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the costs lookup as an [fs::path()]
#' @export
#'
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_hc_costs_path <- function(..., BYOC_MODE = FALSE) {
  if (isTRUE(BYOC_MODE)) {
    hc_costs_path <- file.path(
      denodo_output_path(), "cost_hc_lookup.parquet"
    )
  } else {
    hc_costs_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Costs"),
      file_name = stringr::str_glue(
        "cost_hc_lookup.parquet"
      ),
      ...
    )
  }

  return(hc_costs_path)
}
