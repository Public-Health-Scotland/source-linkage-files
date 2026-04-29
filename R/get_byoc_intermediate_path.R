#' BYOC-to-Denodo S3 Path
#'
#' @description Generates the file paths required to map BYOC outputs to S3,
#' enabling data integration for Denodo views
#'
#' @param type name of dataset e.g. "acute", "mh", "pis"
#' @param year Financial year
#' @param base_path Root directory for outputs. Defaults to "/sdl_byoc/byoc/output"
#' ie denodo_output_path()
#' @return byoc_intermediate_path
#'
#' @examples
#' get_byoc_intermediate_path("homelessness", "1920")
#' "/sdl_byoc/byoc/output/anon-homelessness_for_source-201920.parquet"
#' @export
#' @family file path functions
get_byoc_intermediate_path <- function(type,
                                       year = NULL,
                                       base_path = denodo_output_path()) {

  if (is.null(year)){
  file_name <- dplyr::recode_values(
      type,
      "chi_deaths" ~ "anon-chi_deaths.parquet",
      "combined_deaths" ~ "anon-combined_slf_deaths_lookup.parquet"
      "deaths" ~ "anon-deaths_for_source"
  )
  }else{
  file_name <- dplyr::recode_values(
    type,
    "acute" ~ stringr::str_glue("anon-acute_for_source-20{year}.parquet"),
    "ae" ~ stringr::str_glue("anon-a_and_e_for_source-20{year}.parquet"),
    "cmh" ~ stringr::str_glue("anon-cmh_for_source-20{year}.parquet"),
    "dd" ~ stringr::str_glue("anon-dd_for_source-20{year}.parquet"),
    "nrs_deaths" ~ stringr::str_glue("anon-nrs_deaths_for_source-20{year}.parquet"),
    "dn" ~ stringr::str_glue("anon-district_nursing_for_source-20{year}.parquet"),
    "gp_ooh" ~ stringr::str_glue("anon-gp_ooh_for_source-20{year}.parquet"),
    "homelessness" ~ stringr::str_glue("anon-homelessness_for_source-20{year}.parquet"),
    "ltcs" ~ stringr::str_glue("anon-LTCs_patient_reference_file-20{year}.parquet"),
    "maternity" ~ stringr::str_glue("anon-maternity_for_source-20{year}.parquet"),
    "mh" ~ stringr::str_glue("anon-mental_health_for_source-20{year}.parquet"),
    "outpatients" ~ stringr::str_glue("anon-outpatients_for_source-20{year}.parquet"),
    "pis" ~ stringr::str_glue("anon-prescribing_file_for_source-20{year}.parquet"),
    "sc_client" ~ stringr::str_glue("anon-client_for_source-20{year}.parquet"),
    "sc_at" ~ stringr::str_glue("anon-sc-alarms-telecare-for-source-20{year}.parquet"),
    "sc_ch" ~ stringr::str_glue("anon-sc-care_home_for_source-20{year}.parquet"),
    "sc_hc" ~ stringr::str_glue("anon-sc-home_care_for_source-20{year}.parquet"),
    "sds" ~ stringr::str_glue("anon-sc-sds-for-source-20{year}.parquet")
  )
  }

  # Add the base path
  byoc_intermediate_path <- file.path(base_path, file_name)

  return(byoc_intermediate_path)
}

#' BYOC-to-Denodo S3 Path helper function
#'
#' @description Helper function for the get_byoc_intermediate_path() function
#'
#' @param types named list of the dataset types
#' @param year Financial year
#'
#' @export
#' @family file path functions
get_byoc_output_files <- function(
  year,
  types = NULL
) {
  byoc_input_files <- c(
    "acute",
    "ae",
    "at",
    "ch",
    "cmh",
    "client",
    "dd",
    "deaths",
    "dn",
    "gp_ooh",
    "hc",
    "homelessness",
    "ltcs",
    "maternity",
    "mh",
    "outpatients",
    "pis",
    "sds"
  )

  if (is.null(types)) {
    types <- byoc_input_files
  }

  paths <- purrr::map_chr(
    types,
    ~ get_byoc_intermediate_path(.x, year)
  )

  names(paths) <- types

  as.list(paths)
}
