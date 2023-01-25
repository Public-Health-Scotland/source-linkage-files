#' Read GP OOH Diagnosis extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Diagnosis extract data
read_extract_ooh_diagnosis <- function(
    year,
    file_path = get_boxi_extract_path(year = year, type = "GP_OoH-d")) {
  # Load extract file
  diagnosis_extract <- readr::read_csv(file_path,
    # All columns are character type
    col_types = readr::cols(.default = readr::col_character())
  ) %>%
    # rename variables
    dplyr::rename(
      ooh_case_id = "GUID",
      readcode = "Diagnosis Code",
      description = "Diagnosis Description"
    ) %>%
    tidyr::drop_na(.data$readcode) %>%
    dplyr::distinct()

  return(diagnosis_extract)
}
