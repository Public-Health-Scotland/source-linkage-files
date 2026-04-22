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
  types = NULL,
  base_path = denodo_output_path()
) {
  years <- years_to_run()
  year_specific_types <- c(
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
    "maternity",
    "mh",
    "outpatients",
    "pis",
    "sds"
  )
  non_year_specific_types <- c("combined_deaths_lookup")
  all_types <- c(year_specific_types, non_year_specific_types)

  # if types not supplied, use all types
  if (is.null(types)) {
    types <- all_types
  }

  # check invalid types
  invalid_types <- setdiff(types, all_types)
  if (length(invalid_types) > 0) {
    stop(
      "Unknown type(s): ",
      paste(invalid_types, collapse = ", ")
    )
  }

  # if year not supplied, use all years for year-specific types
  if (is.null(year)) {
    year <- years
  }

  ## build year-specific file names ----
  year_specific_files <- character(0)
  selected_year_specific_types <- intersect(types, year_specific_types)

  if (length(selected_year_specific_types) > 0) {
    file_year_list <- expand.grid(
      file =  dplyr::recode_values(
        selected_year_specific_types,
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
      ),
      year = paste0("-20", year)
    )
    year_specific_files <- paste0(file_year_list$file, file_year_list$year)
    year_specific_files <- file.path(base_path, year_specific_files)
  }

  ## build non-year-specific file names ----
  non_year_specific_types <- intersect(types, non_year_specific_types)
  non_year_specific_files <- dplyr::recode_values(
    non_year_specific_types,
    "combined_deaths_lookup" ~ "anon-combined_slf_deaths_lookup.parquet"
  )
  non_year_specific_files <- file.path(base_path, non_year_specific_files)

  # return a list of path
  as.list(c(year_specific_files, non_year_specific_files))
}
