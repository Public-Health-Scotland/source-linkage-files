#' Read GP OOH Outcomes extract
#'
#' @param year Year of BOXI extract
#'
#' @return a [tibble][tibble::tibble-package] with OOH Outcomes extract data
read_extract_ooh_outcomes <- function(year) {
  extract_outcomes_path <- get_boxi_extract_path(year = year, type = "GP_OoH-o")

  ## Load extract file
  outcomes_extract <- readr::read_csv(extract_outcomes_path,
    # All columns are character type
    col_types = readr::cols(.default = readr::col_character())
  ) %>%
    # rename variables
    dplyr::rename(
      ooh_case_id = "GUID",
      outcome = "Case Outcome"
    ) %>%
    # Remove blank outcomes
    dplyr::filter(.data$outcome != "") %>%
    dplyr::distinct()

  return(outcomes_extract)
}
