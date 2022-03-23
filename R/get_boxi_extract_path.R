#' Get BOXI extract
#'
#' @param year Year of extract
#' @param type Name of BOXI extract
#'
#' @return BOXI extracts containing data for each dataset
#' @export
#'
get_boxi_extract_path <- function(year, type = c("Acute", "Mental", "Outpatient", "AE", "DN", "GPOoH", "Deaths", "CMH", "Homelessness")) {
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year, "Extracts")

  file_name <- dplyr::case_when(
    type == "Acute" ~ "Acute-episode-level-extract",
    type == "Mental" ~ "Mental-Health-episode-level-extract",
    type == "Outpatient" ~ "Outpatients-episode-level-extract",
    type == "AE" ~ "A&E-episode-level-extract",
    type == "DN" ~ "District-Nursing-contact-level-extract",
    type == "GPOoH" ~ "GP-OoH-diagnosis-extract",
    type == "Deaths" ~ "NRS-death-registrations-extract",
    type == "CMH" ~ "Community-MH-contact-level-extract",
    type == "Homelessness" ~ "Homelessness-extract"
  ) %>%
    glue::glue("-20{year}.csv.gz")

  file_path <- get_file_path(
    directory = get_year_dir(year = year, extracts_dir = TRUE),
    file_name = file_name
  )

  return(file_path)
}
