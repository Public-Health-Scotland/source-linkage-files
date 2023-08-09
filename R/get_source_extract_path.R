#' Source Extract File Path
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
get_source_extract_path <- function(
    year,
    type = c(
      "Acute",
      "AE",
      "AT",
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
      "PIS",
      "SDS"
    ),
    ...) {
  if (year %in% type) {
    cli::cli_abort("{.val {year}} was supplied to the {.arg year} argument.")
  }

  year <- check_year_format(year)

  type <- match.arg(type)

  if (!check_year_valid(year, type)) {
    return(NA)
  }

  file_name <- dplyr::case_match(
    type,
    "Acute" ~ "acute_for_source",
    "AE" ~ "a&e_for_source",
    "AT" ~ "Alarms-Telecare-for-source",
    "CH" ~ "care_home_for_source",
    "CMH" ~ "CMH_for_source",
    "Client" ~ "client_for_source",
    "DD" ~ "DD_for_source",
    "Deaths" ~ "deaths_for_source",
    "DN" ~ "DN_for_source",
    "GPOoH" ~ "GP_OOH_for_source",
    "HC" ~ "Home_Care_for_source",
    "Homelessness" ~ "homelessness_for_source",
    "Maternity" ~ "maternity_for_source",
    "MH" ~ "mental_health_for_source",
    "DD" ~ "DD_for_source",
    "Outpatients" ~ "outpatients_for_source",
    "PIS" ~ "prescribing_file_for_source",
    "SDS" ~ "SDS-for-source"
  )

  source_extract_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("{file_name}-20{year}.parquet"),
    ...
  )

  return(source_extract_path)
}
