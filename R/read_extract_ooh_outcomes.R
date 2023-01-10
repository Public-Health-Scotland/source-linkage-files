#' Read GP OOH Outcomes extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for OOH Outcomes
#' @export
#'
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
    dplyr::filter(outcome != "") %>%
    dplyr::distinct()

  return(outcomes_extract)
}
