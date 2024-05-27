#' Read the CHI deaths extract
#'
#' @description This will read the CHI deaths extract and return the data.
#' @param file_path Path to CHI Deaths file
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_it_chi_deaths <- function(file_path = get_it_deaths_path()) {
  it_chi_deaths <- read_file(file_path,
    col_type = readr::cols(
      "PATIENT_UPI [C]" = readr::col_character(),
      "PATIENT DoD DATE (NRS)" = readr::col_date(format = "%d-%m-%Y"),
      "PATIENT DoD DATE (CHI)" = readr::col_date(format = "%d-%m-%Y")
    )
  ) %>%
    dplyr::rename(
      chi = "PATIENT_UPI [C]",
      death_date_nrs = "PATIENT DoD DATE (NRS)",
      death_date_chi = "PATIENT DoD DATE (CHI)"
    )

  return(it_chi_deaths)
}
