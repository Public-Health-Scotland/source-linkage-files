#' Get BOXI extract
#'
#' @param year Year of extract
#' @param type Name of BOXI extract
#'
#' @return BOXI extracts containing data for each dataset
#' @export
#'
extract_path <- function(year, type = c("Acute", "Mental", "Homelessness")) {

  file_name <- dplyr::case_when(
    type == "Acute" ~ "Acute-episode-level-extract",
    type == "Mental" ~ "Mental-Health-episode-level-extract",
    type == "Homelessness" ~ "Homelessness-extract"
  ) %>%
    glue::glue("-20{year}.csv.gz")

  file_path <- get_file_path(directory = get_year_dir(year = year, extracts_dir = TRUE),
                             file_name = file_name)

  return(file_path)
}
