#' Get Source Extract Tests Path
#'
#' @param year Year of extract
#' @param type Name of clean source extract
#'
#' @return Path to clean source extract containing data for each dataset
#' @export
#'
get_source_extract_tests_path <- function(year,
                                          type = c(
                                            "Acute", "AE", "CH", "CMH",
                                            "DD", "DN", "GPOoH", "HC", "Homelessness",
                                            "LTC", "Maternity", "Mental", "NRS",
                                            "Outpatient", "PIS"
                                          ),
                                          extension = c("csv", "sav", "zsav", "rds")) {
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year)

  file_name <- dplyr::case_when(
    type == "Acute" ~ "acute",
    type == "AE" ~ "A&E",
    type == "CH" ~ "care_home",
    type == "CMH" ~ "CMH",
    type == "DD" ~ "DD",
    type == "DN" ~ "DN",
    type == "GPOoH" ~ "GPOoH",
    type == "HC" ~ "HC",
    type == "Homelessness" ~ "homelessness",
    type == "LTC" ~ "LTC",
    type == "Maternity" ~ "maternity",
    type == "Mental" ~ "mental_health",
    type == "NRS" ~ "NRS",
    type == "Outpatient" ~ "outpatient",
    type == "PIS" ~ "PIS"
  )

  file_path <- fs::path(year_dir, glue::glue("{file_name}_tests_20{year}.{extension}"))

  return(file_path)
}
