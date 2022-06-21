#' Source Extract
#'
#' @description Get the file path for Source Extract for given extract and year
#'
#' @param year Year of extract
#' @param ... additional arguments passed to [get_file_path()]
#' @param type Name of clean source extract
#'
#' @return Path to clean source extract containing data for each dataset
#' @export
#'
#' @family extract file paths
get_source_extract_path <- function(year,
                                    type = c(
                                      "Acute",
                                      "AE",
                                      "CH",
                                      "Client",
                                      "CMH",
                                      "DD",
                                      "Deaths",
                                      "DN",
                                      "GPOoH",
                                      "HC",
                                      "Homelessness",
                                      "Maternity",
                                      "MH",
                                      "Outpatients",
                                      "PIS"
                                    ),
                                    ...) {
  type <- match.arg(type)

  year_dir <- fs::path(
    "/conf",
    "sourcedev",
    "Source_Linkage_File_Updates",
    year
  )

  file_name <- dplyr::case_when(
    type == "Acute" ~ "acute_for_source",
    type == "AE" ~ "a&e_for_source",
    type == "CH" ~ "care_home_for_source",
    type == "CMH" ~ "CMH_for_source",
    type == "Client" ~ "client_for_source",
    type == "DD" ~ "DD_for_source",
    type == "Deaths" ~ "deaths_for_source",
    type == "DN" ~ "DN_for_source",
    type == "GPOoH" ~ "GP_OOH_for_source",
    type == "HC" ~ "Home_Care_for_source",
    type == "Homelessness" ~ "homelessness_for_source",
    type == "Maternity" ~ "maternity_for_source",
    type == "MH" ~ "mental_health_for_source",
    type == "DD" ~ "DD_for_source",
    type == "Outpatients" ~ "outpatients_for_source",
    type == "PIS" ~ "prescribing_file_for_source"
  )

  source_extract_path <- get_file_path(
    directory = year_dir,
    file_name = glue::glue("{file_name}-20{year}.rds"),
    ...
  )

  return(source_extract_path)
}
