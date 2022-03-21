#' Get source extract path
#'
#' @param year Year of extract
#' @param type Name of clean source extract
#'
#' @return Path to clean source extract containing data for each dataset
#' @export
#'
get_source_extract_path <- function(year, type = c("Acute", "Mental", "DD")) {
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year)

  file_name <- dplyr::case_when(
    type == "Acute" ~ "acute_for_source",
    type == "Mental" ~ "mental_health_for_source",
    type == "DD" ~ "DD_for_source"
  )

  file_path <- fs::path(year_dir, glue::glue("{file_name}-20{year}.rds"))

  return(file_path)
}
