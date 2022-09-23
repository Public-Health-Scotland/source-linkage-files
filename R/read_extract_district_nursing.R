#' Read district nursing extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for district nursing
#' @export
#'
read_extract_district_nursing <- function(year) {
  extract_district_nursing_path <- get_boxi_extract_path(year = year, type = "DN")

  # Read BOXI extract
  extract_district_nursing <- readr::read_csv(extract_district_nursing_path,
    col_types = cols_only(
      `Treatment NHS Board Code 9` = col_character(),
      `Age at Contact Date` = col_integer(),
      `Contact Date` = col_date(format = "%Y/%m/%d %T"),
      `Primary Intervention Category` = col_character(),
      `Other Intervention Category (1)` = col_character(),
      `Other Intervention Category (2)` = col_character(),
      `Other Intervention Category (3)` = col_character(),
      `Other Intervention Category (4)` = col_character(),
      `UPI Number [C]` = col_character(),
      `Patient DoB Date [C]` = col_date(format = "%Y/%m/%d %T"),
      `Patient Postcode [C] (Contact)` = col_character(),
      `Duration of Contact (measure)` = col_double(),
      Gender = col_double(),
      `Location of Contact` = col_double(),
      `Practice NHS Board Code 9 (Contact)` = col_character(),
      `Patient Council Area Code (Contact)` = col_character(),
      `Practice Code (Contact)` = col_character(),
      `NHS Board of Residence Code 9 (Contact)` = col_character(),
      `HSCP of Residence Code (Contact)` = col_character(),
      `Patient Data Zone 2011 (Contact)` = col_character()
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
      datazone = "Patient Data Zone 2011 (Contact)",
      hbpraccode = "Practice NHS Board Code 9 (Contact)",
      hbtreatcode = "Treatment NHS Board Code 9",
      chi = "UPI Number [C]",
      record_keydate1 = "Contact Date",
      primary_intervention = "Primary Intervention Category",
      intervention_1 = "Other Intervention Category (1)",
      intervention_2 = "Other Intervention Category (2)",
      duration_contact = "Duration of Contact (measure)",
      location_contact = "Location of Contact"
    )

  return(extract_district_nursing)
}
