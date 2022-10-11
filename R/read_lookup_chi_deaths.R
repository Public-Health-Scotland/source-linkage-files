#' Process the CHI deaths lookup
#'
#' @description This will read and process the
#' CHI deaths lookup, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param write_to_disk (optional) Should the data be written to disk default is
#' 'TRUE' i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts

read_lookup_chi_deaths <- function(write_to_disk = TRUE) {

  # Read data -------------------------------------------------------
  deaths_data <- readr::read_csv(
    file = get_it_deaths_path(),
    col_type = cols(
      "PATIENT_UPI [C]" = col_character(),
      "PATIENT DoD DATE (NRS)" = col_date(format = "%d-%m-%Y"),
      "PATIENT DoD DATE (CHI)" = col_date(format = "%d-%m-%Y")
    )
  ) %>%
    # rename variables
    dplyr::rename(
      chi = "PATIENT_UPI [C]",
      death_date_nrs = "PATIENT DoD DATE (NRS)",
      death_date_chi = "PATIENT DoD DATE (CHI)"
    )

  return(deaths_data)
}
