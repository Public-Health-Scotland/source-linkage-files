#' Read CMH extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for Acute
#' @export
#'
read_extract_cmh <- function(year) {
  extract_cmh_path <- get_boxi_extract_path(year = year, type = "CMH")

  # Read BOXI extract
  extract_cmh <- readr::read_csv(extract_cmh_path,
    col_types = cols_only(
      "UPI Number [C]" = col_character(),
      "Patient DoB Date [C]" = col_date(format = "%Y/%m/%d %T"),
      "Gender" = col_double(),
      "Patient Postcode [C]" = col_character(),
      "NHS Board of Residence Code 9" = col_character(),
      "Patient HSCP Code - current" = col_character(),
      "Practice Code" = col_character(),
      "Treatment NHS Board Code 9" = col_character(),
      "Contact Date" = col_date(format = "%Y/%m/%d %T"),
      "Contact Start Time" = col_time(format = "%T"),
      "Duration of Contact" = col_time(format = "%M"),
      "Location of Contact" = col_character(),
      "Main Aim of Contact" = col_character(),
      "Other Aim of Contact (1)" = col_character(),
      "Other Aim of Contact (2)" = col_character(),
      "Other Aim of Contact (3)" = col_character(),
      "Other Aim of Contact (4)" = col_character()
    )
  ) %>%
    # rename
    dplyr::rename(
      chi = "UPI Number [C]",
      dob = "Patient DoB Date [C]",
      gender = "Gender",
      postcode = "Patient Postcode [C]",
      hbrescode = "NHS Board of Residence Code 9",
      hscp = "Patient HSCP Code - current",
      gpprac = "Practice Code",
      hbtreatcode = "Treatment NHS Board Code 9",
      record_keydate1 = "Contact Date",
      keyTime1 = "Contact Start Time",
      duration = "Duration of Contact",
      location = "Location of Contact",
      diag1 = "Main Aim of Contact",
      diag2 = "Other Aim of Contact (1)",
      diag3 = "Other Aim of Contact (2)",
      diag4 = "Other Aim of Contact (3)",
      diag5 = "Other Aim of Contact (4)"
    )

  return(extract_cmh)
}
