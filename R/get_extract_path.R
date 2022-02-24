#' Get BOXI extract
#'
#' @param year Year of extract
#' @param type Name of BOXI extract
#'
#' @return BOXI extracts containing data for each dataset
#' @export
#'
extract_path <- function(year, type = c("Acute", "Mental", "Homelessness")) {
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year, "Extracts")

  file_name <- dplyr::case_when(
    type == "Acute" ~ "Acute-episode-level-extract",
    type == "Mental" ~ "Mental-Health-episode-level-extract",
    type == "Homelessness" ~ "Homelessness-extract"
  )

  file_path <- fs::path(year_dir, glue::glue("{file_name}-20{year}.csv.gz"))

  if (fs::file_exists(fs::path_ext_remove(file_path))) {
    file_path <- fs::path_ext_remove(file_path)
  } else if (!fs::file_exists(file_path)) {
    rlang::abort(glue::glue("{type} Extract not found"))
  }

  return(file_path)
}
