#' Read Prescribing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_prescribing <- function(year, file_path = get_it_prescribing_path(year)) {
  log_slf_event(stage = "read", status = "start", type = "pis", year = year)

  pis_file <- read_file(file_path) %>%
    # Rename variables
    dplyr::select(
      anon_chi = "anon_chi",
      dob = "Pat DoB [C]",
      gender = "Pat Gender",
      postcode = "Pat Postcode [C]",
      gpprac = "Practice Code",
      no_paid_items = "Number of Paid Items",
      cost_total_net = "PD Paid GIC excl. BB"
    ) %>%
    # format prescribing
    dplyr::mutate(
      dob = lubridate::dmy(.data$dob)
    )

  log_slf_event(stage = "read", status = "complete", type = "pis", year = year)

  return(pis_file)
}
