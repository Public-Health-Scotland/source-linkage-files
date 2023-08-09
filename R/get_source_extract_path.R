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
get_source_extract_path <- function(year,
                                    type = c(
                                      "acute",
                                      "ae",
                                      "at",
                                      "ch",
                                      "client",
                                      "cmh",
                                      "dd",
                                      "deaths",
                                      "dn",
                                      "gp_ooh",
                                      "hc",
                                      "homelessness",
                                      "maternity",
                                      "mh",
                                      "outpatients",
                                      "pis",
                                      "sds"
                                    ),
                                    ...) {
  type <- match.arg(type)

  if (!check_year_valid(year, type)) {
    return(NA)
  }

  file_name <- dplyr::case_match(
    type,
    "acute" ~ "acute_for_source",
    "ae" ~ "a&e_for_source",
    "at" ~ "alarms-telecare-for-source",
    "ch" ~ "care_home_for_source",
    "cmh" ~ "cmh_for_source",
    "client" ~ "client_for_source",
    "dd" ~ "dd_for_source",
    "deaths" ~ "deaths_for_source",
    "dn" ~ "dn_for_source",
    "gp_ooh" ~ "gp_ooh_for_source",
    "hc" ~ "home_care_for_source",
    "homelessness" ~ "homelessness_for_source",
    "maternity" ~ "maternity_for_source",
    "mh" ~ "mental_health_for_source",
    "dd" ~ "dd_for_source",
    "outpatients" ~ "outpatients_for_source",
    "pis" ~ "prescribing_file_for_source",
    "sds" ~ "sds-for-source"
  )

  source_extract_path <- get_file_path(
    directory = get_year_dir(year),
    file_name = stringr::str_glue("{file_name}-20{year}.parquet"),
    ...
  )

  return(source_extract_path)
}
