#' Read Prescribing extract
#'
#' @param year Year of extract
#'
#' @return csv data file for prescribing
#' @export
#'
read_extract_prescribing <- function(year) {
    get_it_prescribing_path(year),
    col_type = cols_only(
      `Pat UPI [C]` = col_character(),
      `Pat DoB [C]` = col_date(format = "%d-%m-%Y"),
      `Pat Gender` = col_double(),
      `Pat Postcode [C]` = col_character(),
      `Practice Code` = col_character(),
      `Number of Dispensed Items` = col_double(),
      `DI Paid NIC excl. BB` = col_double()
    )
  ) %>%
    # Rename variables
    dplyr::rename(
      chi = "Pat UPI [C]",
      dob = "Pat DoB [C]",
      gender = "Pat Gender",
      postcode = "Pat Postcode [C]",
      gpprac = "Practice Code",
      no_dispensed_items = "Number of Dispensed Items",
      cost_total_net = "DI Paid NIC excl. BB"
    )

  return(pis_file)

}

  pis_file <- readr::read_csv(
#' Read PIS extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for PIS
#' @export
#'
read_extract_pis <- function(year) {
  extract_pis_path <- get_it_prescribing_path(year)

  pis_file <- readr::read_csv(extract_pis_path,
    col_type = cols_only(
      `Pat UPI [C]` = col_character(),
      `Pat DoB [C]` = col_date(format = "%d-%m-%Y"),
      `Pat Gender` = col_double(),
      `Pat Postcode [C]` = col_character(),
      `Practice Code` = col_character(),
      `Number of Dispensed Items` = col_double(),
      `DI Paid NIC excl. BB` = col_double()
    )
  ) %>%
    # Rename variables
    dplyr::rename(
      chi = "Pat UPI [C]",
      dob = "Pat DoB [C]",
      gender = "Pat Gender",
      postcode = "Pat Postcode [C]",
      gpprac = "Practice Code",
      no_dispensed_items = "Number of Dispensed Items",
      cost_total_net = "DI Paid NIC excl. BB"
    )

  return(pis_file)
}
