extract_path <- function(year, type = c("Acute", "Mental")) {
  year_dir <- path("/conf/sourcedev/Source_Linkage_File_Updates", year, "Extracts")

  file_name <- case_when(
    type == "Acute" ~ "Acute-episode-level-extract",
    type == "Mental" ~ "Mental-Health-episode-level-extract"
  )

  file_path <- path(year_dir, glue::glue("{file_name}-20{year}.csv.gz"))

  if (file_exists(path_ext_remove(file_path))) {
    file_path <- path_ext_remove(file_path)
  } else if (!file_exists(file_path)) {
    rlang::abort(glue::glue("{type} Extract not found"))
  }

  return(file_path)
}
