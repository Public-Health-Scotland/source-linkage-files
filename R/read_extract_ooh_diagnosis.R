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
  log_slf_event(stage = "read", status = "start", type = "gp_ooh-d", year = year)

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path()) {
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
      sc_start_financial_year == c_year,
      out_of_hours_services_flag == "Y"
    ) %>%
    # rename variables
    dplyr::select(
      ooh_case_id = "guid",
      readcode = "diagnosis_code",
      description = "diagnosis_desc"
    ) %>%
    dplyr::distinct() %>%
    dplyr::collect() %>%
    tidyr::drop_na(readcode)

  log_slf_event(stage = "read", status = "complete", type = "gp_ooh-d", year = year)

  return(diagnosis_extract)
}
