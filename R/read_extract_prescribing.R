#' Read Prescribing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_prescribing <- function(year, file_path = get_it_prescribing_path(year)) {
  pis_file <- read_file(file_path,
    col_type = readr::cols_only(
      "anon_chi" = readr::col_character(),
      "Pat DoB [C]" = readr::col_date(format = "%d-%m-%Y"),
      "Pat Gender" = readr::col_double(),
      "Pat Postcode [C]" = readr::col_character(),
      "Practice Code" = readr::col_character(),
      "Number of Paid Items" = readr::col_double(),
      "PD Paid GIC excl. BB" = readr::col_double()
    )
  ) %>%
    # Rename variables
    dplyr::rename(
      anon_chi = "anon_chi",
      dob = "Pat DoB [C]",
      gender = "Pat Gender",
      postcode = "Pat Postcode [C]",
      gpprac = "Practice Code",
      no_paid_items = "Number of Paid Items",
      cost_total_net = "PD Paid GIC excl. BB"
    ) %>%
    slfhelper::get_chi()

  return(pis_file)
}
