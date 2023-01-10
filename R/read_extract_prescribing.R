#' Read Prescribing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_prescribing <- function(year) {
  # TODO remove Number of Dispensed Items, DI Paid NIC excl. BB, DI Paid GIC excl. BB and PD Paid NIC excl. BB when the extract changes.
  pis_file <- readr::read_csv(
    get_it_prescribing_path(year),
    col_type = cols_only(
      "Pat UPI [C]" = col_character(),
      "Pat DoB [C]" = col_date(format = "%d-%m-%Y"),
      "Pat Gender" = col_double(),
      "Pat Postcode [C]" = col_character(),
      "Practice Code" = col_character(),
      "Number of Dispensed Items" = col_double(),
      "DI Paid NIC excl. BB" = col_double(),
      "DI Paid GIC excl. BB" = col_double(),
      "Number of Paid Items" = col_double(),
      "PD Paid NIC excl. BB" = col_double(),
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
      no_dispensed_items = "Number of Dispensed Items",
      no_paid_items = "Number of Paid Items",
      cost_total_net = "PD Paid GIC excl. BB"
    ) %>%
    dplyr::select(
      -"PD Paid NIC excl. BB",
      -"DI Paid NIC excl. BB",
      -"DI Paid GIC excl. BB"
    )

  return(pis_file)
}
