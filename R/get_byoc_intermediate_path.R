#' BYOC intermediate Denodo output paths
#'
#' @description Build BYOC intermediate Denodo output paths
#'
#' @param type name of dataset e.g. "acute", "mh", "pis".
#' @param year Financial year
#' @param base_path Root directory for outputs. Defaults to "/sdl_byoc/byoc/output".
#'
#' @return byoc_intermediate_path
#'
#' @examples
#' get_byoc_intermediate_path("homelessness", "1920")
#' "/sdl_byoc/byoc/output/anon-homelessness_for_source-201920.parquet"
#' @export
#' @family file path functions

get_byoc_intermediate_path <- function(type,
                                       year,
                                       base_path = "/sdl_byoc/byoc/output") {
  file_name <- dplyr::case_match(
    type,
    "acute" ~ "anon-acute_for_source",
    "ae" ~ "anon-a_and_e_for_source",
    "at" ~ "anon-alarms-telecare-for-source",
    "ch" ~ "anon-care_home_for_source",
    "cmh" ~ "anon-cmh_for_source",
    "client" ~ "anon-client_for_source",
    "dd" ~ "anon-dd_for_source",
    "deaths" ~ "anon-deaths_for_source",
    "dn" ~ "anon-district_nursing_for_source",
    "gp_ooh" ~ "anon-gp_ooh_for_source",
    "hc" ~ "anon-home_care_for_source",
    "homelessness" ~ "anon-homelessness_for_source",
    "maternity" ~ "anon-maternity_for_source",
    "mh" ~ "anon-mental_health_for_source",
    "outpatients" ~ "anon-outpatients_for_source",
    "pis" ~ "anon-prescribing_file_for_source",
    "sds" ~ "anon-sds-for-source"
  )

  file_name <- stringr::str_glue("{file_name}-20{year}.parquet")

  # Add the base path
  byoc_intermediate_path <- file.path(base_path, file_name)

  return(byoc_intermediate_path)
}
