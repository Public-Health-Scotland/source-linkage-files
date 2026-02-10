#' Denodo file output path
#' @export
denodo_output_path <- function() {
  "/sdl_byoc/byoc/output"
}

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
                                    BYOC_MODE,
                                    ...) {
  if (year %in% type) {
    cli::cli_abort("{.val {year}} was supplied to the {.arg year} argument.")
  }

  year <- check_year_format(year)

  type <- match.arg(type)

  if (!check_year_valid(year, type)) {
    return(get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE))
  }

  file_name <- dplyr::case_match(
    type,
    "acute" ~ "anon-acute_for_source",
    "ae" ~ "anon-a_and_e_for_source",
    "at" ~ "anon-alarms-telecare-for-source",
    "ch" ~ "anon-care_home_for_source",
    "cmh" ~ "anon-cmh_for_source",
    "client" ~ "anon-client_for_source",
    "dd" ~ "anon-delayed_discharge_for_source",
    "deaths" ~ "anon-deaths_for_source",
    "dn" ~ "anon-district_nursing_for_source",
    "gp_ooh" ~ "anon-gp_ooh_for_source",
    "hc" ~ "anon-home_care_for_source",
    "homelessness" ~ "anon-homelessness_for_source",
    "maternity" ~ "anon-maternity_for_source",
    "mh" ~ "anon-mental_health_for_source",
    "dd" ~ "anon-dd_for_source",
    "outpatients" ~ "anon-outpatients_for_source",
    "pis" ~ "anon-prescribing_file_for_source",
    "sds" ~ "anon-sds-for-source"
  ) %>%
    stringr::str_glue("-20{year}.parquet")

  if (BYOC_MODE) {
    source_extract_path <- file.path(
      directory = denodo_output_path(),
      # todo: waiting to be finalised
      file_name = file_name
    )
  } else {
    source_extract_path <- get_file_path(
      directory = get_year_dir(year, BYOC_MODE = BYOC_MODE),
      file_name = file_name,
      ...
    )
  }

  return(source_extract_path)
}
