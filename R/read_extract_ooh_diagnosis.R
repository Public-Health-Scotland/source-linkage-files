#' Read GP OOH Diagnosis extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Diagnosis extract data
#'
read_extract_ooh_diagnosis <- function(
  year,
  denodo_connect, ## TO-DO: will be hardcoded to denodo_connect = get_denodo_connection() ##
  file_path = get_boxi_extract_path(year = year, type = "gp_ooh-d", BYOC_MODE),
  BYOC_MODE
) {

  year <- check_year_format(year, format = "fyyear")
  c_year <- convert_fyyear_to_year(year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  }

  # Load extract file
  diagnosis_extract <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_gp_ooh_diagnosis_source")
  ) %>%
    dplyr::filter(financial_year == c_year) %>%
    # rename variables
    dplyr::select(
      ooh_case_id = "GUID", ## TO-DO: needs to be renamed by NSS to match file spec - guid ##
      readcode = "diagnosis_code",
      description = "Diagnosis_Description" ## TO-DO: needs to be renamed by NSS to match ##
                                            ## file spec - diagnosis_desc ##
    ) %>%
    dplyr::distinct() %>%
    dplyr::collect() %>%
    tidyr::drop_na(.data$readcode)

  return(diagnosis_extract)
}
