#' Read GP OOH Diagnosis extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Diagnosis extract data
#'
read_extract_ooh_diagnosis <- function(
  year,
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  file_path = get_boxi_extract_path(year = year, type = "gp_ooh-d", BYOC_MODE),
  BYOC_MODE
) {
  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  }

  # Disconnect from Denodo
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Load extract file
  diagnosis_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gp_ooh_diagnosis_source")
  ) %>%
    # Filter to match BOXI extraction
    dplyr::filter(
      sc_start_financial_year == c_year, # TO-DO: filtered variables are not currently in the denodo view.
      out_of_hours_services_flag == "Y"
    ) %>% # Feedback given to NSS via UAT.
    # rename variables
    dplyr::select(
      ooh_case_id = "GUID", ## TO-DO: needs to be renamed by NSS to match file spec - guid ##
      readcode = "diagnosis_code",
      description = "Diagnosis_Description" ## TO-DO: needs to be renamed by NSS to match ##
      ## file spec - diagnosis_desc ##
    ) %>%
    dplyr::distinct() %>%
    dplyr::collect() %>%
    tidyr::drop_na(readcode)

  return(diagnosis_extract)
}
