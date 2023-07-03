#' Read Prescribing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_prescribing <- function(year, file_path = get_it_prescribing_path(year)) {
  pis_file <- read_file(file_path,
    col_type = cols_only(
      "Pat UPI [C]" = col_character(),
      "Pat DoB [C]" = col_date(format = "%d-%m-%Y"),
      "Pat Gender" = col_double(),
      "Pat Postcode [C]" = col_character(),
      "Practice Code" = col_character(),
      "Number of Paid Items" = col_double(),
      "PD Paid GIC excl. BB" = col_double()
    )
  ) %>%
    # Rename variables
    dplyr::rename(
      chi = "Pat UPI [C]",
      dob = "Pat DoB [C]",
      gender = "Pat Gender",
      postcode = "Pat Postcode [C]",
      gpprac = "Practice Code",
      no_paid_items = "Number of Paid Items",
      cost_total_net = "PD Paid GIC excl. BB"
    )

  return(pis_file)
}
