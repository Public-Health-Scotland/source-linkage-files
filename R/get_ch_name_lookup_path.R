#' Get the full path to the Year Specific Care Home Lookup
#'
#' @param year Year of extract
#' @param ext Extension for the extract (zsav or rds)
#'
#' @return Path to clean source extract containing data for each dataset
#' @export
get_ch_name_lookup_path <- function(year, ...) {

  year_dir <- paste0(get_year_dir(year), "/Extracts")


  lookup_path <- get_file_path(
    directory = year_dir,
    file_name = glue::glue("Care_home_name_lookup-20{year}.rds"),
    ...
  )

  return(lookup_path)
}
