#' Year Specific Care Home Name Lookup
#'
#' @description Get the full file path to the Year Specific Care Home Lookup
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [get_file_path()]

#'
#' @return Path to clean source extract containing data for each dataset
#' @export
#'
#' @family social care lookup file paths
get_ch_name_lookup_path <- function(year, ...) {
  year_dir <- paste0(get_year_dir(year), "/Extracts")

  lookup_path <- get_file_path(
    directory = year_dir,
    file_name = glue::glue("Care_home_name_lookup-20{year}.rds"),
    ...
  )

  return(lookup_path)
}
