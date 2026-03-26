#' Read CMH extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_cmh <- function(
  year,
  file_path = get_boxi_extract_path(year = year, type = "cmh")
) {
  log_slf_event(stage = "read", status = "start", type = "cmh", year = year)

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path()) {
    return(tibble::tibble())
  }

  # Read BOXI extract
  extract_cmh <- read_file(file_path,
    col_types = readr::cols_only(
      "anon_chi" = readr::col_character(),
      "Patient DoB Date [C]" = readr::col_date(format = "%Y/%m/%d %T"),
      "Gender" = readr::col_double(),
      "Patient Postcode [C]" = readr::col_character(),
      "NHS Board of Residence Code 9" = readr::col_character(),
      "Patient HSCP Code - current" = readr::col_character(),
      "Practice Code" = readr::col_integer(),
      "Treatment NHS Board Code 9" = readr::col_character(),
      "Contact Date" = readr::col_date(format = "%Y/%m/%d %T"),
      "Contact Start Time" = readr::col_time(format = "%T"),
      "Duration of Contact" = readr::col_integer(),
      "Location of Contact" = readr::col_character(),
      "Main Aim of Contact" = readr::col_character(),
      "Other Aim of Contact (1)" = readr::col_character(),
      "Other Aim of Contact (2)" = readr::col_character(),
      "Other Aim of Contact (3)" = readr::col_character(),
      "Other Aim of Contact (4)" = readr::col_character()
    )
  ) %>%
    # rename
    dplyr::rename(
      anon_chi = "anon_chi",
      dob = "Patient DoB Date [C]",
      gender = "Gender",
      postcode = "Patient Postcode [C]",
      hbrescode = "NHS Board of Residence Code 9",
      hscp = "Patient HSCP Code - current",
      gpprac = "Practice Code",
      hbtreatcode = "Treatment NHS Board Code 9",
      record_keydate1 = "Contact Date",
      keytime1 = "Contact Start Time",
      duration = "Duration of Contact",
      location = "Location of Contact",
      diag1 = "Main Aim of Contact",
      diag2 = "Other Aim of Contact (1)",
      diag3 = "Other Aim of Contact (2)",
      diag4 = "Other Aim of Contact (3)",
      diag5 = "Other Aim of Contact (4)"
    )

  log_slf_event(stage = "read", status = "complete", type = "cmh", year = year)

  return(extract_cmh)
}
