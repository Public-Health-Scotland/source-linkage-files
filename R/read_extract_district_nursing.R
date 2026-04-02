#' Read district nursing extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_district_nursing <- function(
  year,
  file_path = get_boxi_extract_path(year = year, type = "dn")
) {
  log_slf_event(stage = "read", status = "start", type = "dn", year = year)

  if (file_path == get_dummy_boxi_extract_path()) {
    return(tibble::tibble())
  }

  # Read BOXI extract
  extract_district_nursing <- read_file(file_path,
    col_types = readr::cols_only(
      `Treatment NHS Board Code 9` = readr::col_character(),
      `Age at Contact Date` = readr::col_integer(),
      `Contact Date` = readr::col_date(format = "%Y/%m/%d %T"),
      `Primary Intervention Category` = readr::col_character(),
      `Other Intervention Category (1)` = readr::col_character(),
      `Other Intervention Category (2)` = readr::col_character(),
      `anon_chi` = readr::col_character(),
      `Patient DoB Date [C]` = readr::col_date(format = "%Y/%m/%d %T"),
      `Patient Postcode [C] (Contact)` = readr::col_character(),
      `Duration of Contact (measure)` = readr::col_double(),
      Gender = readr::col_double(),
      `Location of Contact` = readr::col_character(),
      `Practice NHS Board Code 9 (Contact)` = readr::col_character(),
      `Patient Council Area Code (Contact)` = readr::col_character(),
      `Practice Code (Contact)` = readr::col_character(),
      `NHS Board of Residence Code 9 (Contact)` = readr::col_character(),
      `HSCP of Residence Code (Contact)` = readr::col_character(),
      `Patient Data Zone 2011 (Contact)` = readr::col_character()
    )
  ) %>%
    # rename
    dplyr::rename(
      age = "Age at Contact Date",
      dob = "Patient DoB Date [C]",
      gender = "Gender",
      hscp = "HSCP of Residence Code (Contact)",
      hbrescode = "NHS Board of Residence Code 9 (Contact)",
      lca = "Patient Council Area Code (Contact)",
      postcode = "Patient Postcode [C] (Contact)",
      gpprac = "Practice Code (Contact)",
      hbpraccode = "Practice NHS Board Code 9 (Contact)",
      hbtreatcode = "Treatment NHS Board Code 9",
      anon_chi = "anon_chi",
      record_keydate1 = "Contact Date",
      primary_intervention = "Primary Intervention Category",
      intervention_1 = "Other Intervention Category (1)",
      intervention_2 = "Other Intervention Category (2)",
      duration_contact = "Duration of Contact (measure)",
      location_contact = "Location of Contact"
    )

  log_slf_event(stage = "read", status = "complete", type = "dn", year = year)

  return(extract_district_nursing)
}
