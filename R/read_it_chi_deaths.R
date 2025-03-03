#' Read the CHI deaths extract
#'
#' @description This will read the CHI deaths extract and return the data.
#' @param file_path Path to CHI Deaths file
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
read_it_chi_deaths <- function(file_path = get_it_deaths_path()) {
  it_chi_deaths <- read_file(file_path) %>%
    dplyr::select(
      anon_chi = "anon_chi",
      death_date_nrs = "PATIENT DoD DATE (NRS)",
      death_date_chi = "PATIENT DoD DATE (CHI)"
    ) %>%
    dplyr::mutate(
      death_date_nrs = lubridate::ymd(as.Date(death_date_nrs)),
      death_date_chi = lubridate::ymd(as.Date(death_date_chi))
    )

  return(it_chi_deaths)
}
