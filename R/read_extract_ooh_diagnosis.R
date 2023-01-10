#' Read GP OOH Diagnosis extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for OOH Diagnosis
#' @export
#'
read_extract_ooh_diagnosis <- function(year) {
  extract_diagnosis_path <- get_boxi_extract_path(year = year, type = "GP_OoH-d")

  # Load extract file
  diagnosis_extract <- readr::read_csv(extract_diagnosis_path,
    # All columns are character type
    col_types = readr::cols(.default = readr::col_character())
  ) %>%
    # rename variables
    dplyr::rename(
      ooh_case_id = "GUID",
      readcode = "Diagnosis Code",
      description = "Diagnosis Description"
    ) %>%
    tidyr::drop_na(readcode) %>%
    dplyr::distinct()

  return(diagnosis_extract)
}
