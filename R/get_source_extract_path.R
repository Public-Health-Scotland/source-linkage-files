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
    return(get_dummy_boxi_extract_path())
  }

  file_name <- dplyr::case_match(
    type,
    "Acute" ~ "acute_for_source",
    "AE" ~ "a_and_e_for_source",
    "AT" ~ "alarms-telecare-for-source",
    "CH" ~ "care_home_for_source",
    "CMH" ~ "cmh_for_source",
    "DD" ~ "delayed_discharge_for_source",
    "Deaths" ~ "deaths_for_source",
    "DN" ~ "district_nursing_for_source",
    "GPOoH" ~ "gp_ooh_for_source",
    "HC" ~ "home_care_for_source",
    "Homelessness" ~ "homelessness_for_source",
    "Maternity" ~ "maternity_for_source",
    "MH" ~ "mental_health_for_source",
    "Outpatients" ~ "outpatients_for_source",
    "PIS" ~ "prescribing_for_source",
    "SDS" ~ "sds_for_source"
  ) %>%
    stringr::str_glue("-{year}.parquet")

  source_extract_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = file_name,
    ...
  )

  return(source_extract_path)
}
