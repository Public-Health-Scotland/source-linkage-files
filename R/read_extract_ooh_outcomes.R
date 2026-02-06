#' Read GP OOH Outcomes extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Outcomes extract data
read_extract_ooh_outcomes <- function(
  year,
  file_path = get_boxi_extract_path(year = year, type = "gp_ooh-o")
) {
  log_slf_event(stage = "read", status = "start", type = "gp_ooh-o", year = year)

  ## Load extract file
  outcomes_extract <- read_file(file_path,
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

  log_slf_event(stage = "read", status = "complete", type = "gp_ooh-o", year = year)

  return(outcomes_extract)
}
