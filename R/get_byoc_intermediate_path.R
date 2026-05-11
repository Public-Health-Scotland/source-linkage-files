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
# Dataset registry - This is where the names will be updated--------------------
.byoc_dataset_registry <- tibble::tribble(
  ~type, ~file_stub, ~year_specific,

  # Year‑specific datasets -----------------------------------------------------
  "acute", "anon-acute_for_source", TRUE,
  "ae", "anon-a_and_e_for_source", TRUE,
  "at", "anon-alarms-telecare-for-source", TRUE,
  "ch", "anon-care_home_for_source", TRUE,
  "cmh", "anon-cmh_for_source", TRUE,
  "client", "anon-client_for_source", TRUE,
  "dd", "anon-dd_for_source", TRUE,
  "deaths", "anon-deaths_for_source", TRUE,
  "nrs_deaths", "anon-nrs_deaths_for_source", TRUE,
  "dn", "anon-district_nursing_for_source", TRUE,
  "gp_ooh", "anon-gp_ooh_for_source", TRUE,
  "hc", "anon-home_care_for_source", TRUE,
  "homelessness", "anon-homelessness_for_source", TRUE,
  "ltcs", "anon-LTCs_patient_reference_file", TRUE,
  "maternity", "anon-maternity_for_source", TRUE,
  "mh", "anon-mental_health_for_source", TRUE,
  "outpatients", "anon-outpatients_for_source", TRUE,
  "pis", "anon-prescribing_file_for_source", TRUE,
  "sds", "anon-sc-sds-for-source", TRUE,

  # Non‑year‑specific / static datasets ----------------------------------------
  "chi_deaths", "anon-chi_deaths.parquet", FALSE,
  "combined_deaths", "anon-combined_slf_deaths_lookup.parquet", FALSE,
  "sc_all_at", "anon-all_at_episodes.parquet", FALSE,
  "sc_all_ch", "anon-all_ch_episodes.parquet", FALSE,
  "sc_all_hc", "anon-all_hc_episodes.parquet", FALSE,
  "sc_all_sds", "anon-all_sds_episodes.parquet", FALSE,
  "homelessness_completeness", "homelessness_completeness.parquet", FALSE,
  "ch_cost_lookup", "Cost_CH_Lookup.parquet", FALSE,
  "dn_cost_lookup", "Cost_DN_Lookup.parquet", FALSE,
  "hc_cost_lookup", "cost_hc_lookup.parquet", FALSE,
  "ooh_cost_lookup", "Cost_GPOoH_Lookup.parquet", FALSE
)

get_byoc_intermediate_path <- function(
  file_name,
  base_path = denodo_output_path()
) {
  file.path(base_path, file_name)
}

#' Helper function to build the BYOC output file paths as a named list
#'
#' @description Helper function for the get_byoc_intermediate_path() function
#'
#' @param types named list of the dataset types
#' @param year Financial year
#' @param base_path Root output directory
#'
#' @return Named list of file paths
#'
#' @export
#' @family file path functions
get_byoc_output_files <- function(
  years,
  types = NULL,
  base_path = denodo_output_path()
) {
  registry <- .byoc_dataset_registry

  # validate types
  if (!is.null(types)) {
    invalid <- setdiff(types, registry$type)
    if (length(invalid) > 0) {
      stop(
        "Unknown dataset type(s): ",
        paste(invalid, collapse = ", ")
      )
    }
    registry <- dplyr::filter(registry, type %in% types)
  }

  # year‑specific datasets (expanded for all years)
  year_specific_paths <- registry %>%
    dplyr::filter(year_specific) %>%
    tidyr::expand_grid(year = years) %>%
    dplyr::mutate(
      name = paste0(type, "_", year),
      file = paste0(file_stub, "-20", year, ".parquet"),
      path = get_byoc_intermediate_path(file, base_path)
    )

  # non‑year‑specific datasets (once only)
  static_paths <- registry %>%
    dplyr::filter(!year_specific) %>%
    dplyr::mutate(
      name = type,
      file = file_stub,
      path = get_byoc_intermediate_path(file, base_path)
    )

  # combine and return named list
  all_paths <- dplyr::bind_rows(
    year_specific_paths,
    static_paths
  )

  result <- all_paths %>%
    dplyr::group_by(type) %>%
    dplyr::summarise(path = list(path), .groups = "drop")

  paths <- result$path
  names(paths) <- result$type

  paths
}
