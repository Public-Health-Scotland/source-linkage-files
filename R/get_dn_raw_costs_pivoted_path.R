#' Pivoted Raw District Nursing Costs File Path
#'
#' @description Get the Pivoted District Nursing raw costs path
#'
#' @inheritParams get_ch_costs_path
#'
#' @return The path to the pivoted costs lookup as an [fs::path()]
#' @export
#' @family costs lookup file paths
#' @seealso [get_file_path()] for the generic function.
get_dn_raw_costs_pivoted_path <- function(...) {
  dn_raw_costs_pivoted_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Costs"),
    file_name = stringr::str_glue("dn_costs_pivoted.csv"),
    ...
  )

  return(dn_raw_costs_pivoted_path)
}



