#' Get Source Extract path
#'
#' @param year Year of extract
#' @param type Name of clean source extract
#' @param ext Extension for the extract (zsav or rds)
#'
#' @return Path to clean source extract containing data for each dataset
#' @export
#'
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
                                      "Mental",
                                      "Outpatients",
                                      "PIS"
                                    ),
                                    ext = c("zsav", "rds")) {
  type <- match.arg(type)
  ext <- match.arg(ext)

  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year)

  file_name <- dplyr::case_when(
    type == "Acute" ~ "acute_for_source",
    type == "AE" ~ "a&e_for_source",
    type == "CH" ~ "care_home_for_source",
    type == "CMH" ~ "CMH_for_source",
    type == "Client" ~ "client_for_Source",
    type == "DD" ~ "DD_for_source",
    type == "Deaths" ~ "deaths_for_source",
    type == "DN" ~ "DN_for_source",
    type == "GPOoH" ~ "GP_OOH_for_source",
    type == "HC" ~ "Home_Care_for_source",
    type == "Homelessness" ~ "homelessness_for_source",
    type == "Maternity" ~ "maternity_for_source",
    type == "Mental" ~ "mental_health_for_source",
    type == "DD" ~ "DD_for_source",
    type == "Client" ~ "Client_for_Source"
    type == "Outpatients" ~ "outpatients_for_source",
    type == "PIS" ~ "prescribing_file_for_source"
  )

  source_extract_path <- get_file_path(
    directory = year_dir,
    file_name = glue::glue("{file_name}-20{year}"),
    ext = ext,
    check_mode = "write"
  )

  return(source_extract_path)
}
