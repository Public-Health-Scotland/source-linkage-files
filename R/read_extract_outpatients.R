#' Read Outpatients extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_outpatients <- function(
    year,
    file_path = get_boxi_extract_path(year = year, type = "outpatient")) {
  # Read BOXI extract
  extract_outpatients <- read_file(file_path,
    col_type = readr::cols(
      "Clinic Date Fin Year" = readr::col_double(),
      "Clinic Date (00)" = readr::col_date(format = "%Y/%m/%d %T"),
      "Episode Record Key (SMR00) [C]" = readr::col_character(),
      "Pat UPI" = readr::col_character(),
      "Pat Gender Code" = readr::col_double(),
      "Pat Date Of Birth [C]" = readr::col_date(format = "%Y/%m/%d %T"),
      "Practice Location Code" = readr::col_character(),
      "Practice NHS Board Code - current" = readr::col_character(),
      "Geo Postcode [C]" = readr::col_character(),
      "NHS Board of Residence Code - current" = readr::col_character(),
      "Geo Council Area Code" = readr::col_character(),
      "Treatment Location Code" = readr::col_character(),
      "Treatment NHS Board Code - current" = readr::col_character(),
      "Operation 1A Code (4 char)" = readr::col_character(),
      "Operation 1B Code (4 char)" = readr::col_character(),
      "Date of Main Operation(00)" = readr::col_date(format = "%Y/%m/%d %T"),
      "Operation 2A Code (4 char)" = readr::col_character(),
      "Operation 2B Code (4 char)" = readr::col_character(),
      "Date of Operation 2 (00)" = readr::col_date(format = "%Y/%m/%d %T"),
      "Specialty Classificat. 1/4/97 Code" = readr::col_character(),
      "Significant Facility Code" = readr::col_character(),
      "Consultant/HCP Code" = readr::col_character(),
      "Patient Category Code" = readr::col_character(),
      "Referral Source Code" = readr::col_character(),
      "Referral Type Code" = readr::col_double(),
      "Clinic Type Code" = readr::col_double(),
      "Clinic Attendance (Status) Code" = readr::col_double(),
      "Age at Midpoint of Financial Year" = readr::col_double(),
      "Alcohol Related Admission" = readr::col_character(),
      "Substance Misuse Related Admission" = readr::col_character(),
      "Falls Related Admission" = readr::col_character(),
      "Self Harm Related Admission" = readr::col_character(),
      "NHS Hospital Flag" = readr::col_character(),
      "Community Hospital Flag" = readr::col_character(),
      "Total Net Costs" = readr::col_double()
    )
  ) %>%
    # Rename variables
    dplyr::rename(
      clinic_date_fy = "Clinic Date Fin Year",
      record_keydate1 = "Clinic Date (00)",
      dob = "Pat Date Of Birth [C]",
      age = "Age at Midpoint of Financial Year",
      alcohol_adm = "Alcohol Related Admission",
      attendance_status = "Clinic Attendance (Status) Code",
      clinic_type = "Clinic Type Code",
      commhosp = "Community Hospital Flag",
      conc = "Consultant/HCP Code",
      uri = "Episode Record Key (SMR00) [C]",
      falls_adm = "Falls Related Admission",
      lca = "Geo Council Area Code",
      postcode = "Geo Postcode [C]",
      hbrescode = "NHS Board of Residence Code - current",
      nhshosp = "NHS Hospital Flag",
      op1a = "Operation 1A Code (4 char)",
      op1b = "Operation 1B Code (4 char)",
      dateop1 = "Date of Main Operation(00)",
      op2a = "Operation 2A Code (4 char)",
      op2b = "Operation 2B Code (4 char)",
      dateop2 = "Date of Operation 2 (00)",
      gender = "Pat Gender Code",
      chi = "Pat UPI",
      cat = "Patient Category Code",
      gpprac = "Practice Location Code",
      hbpraccode = "Practice NHS Board Code - current",
      refsource = "Referral Source Code",
      reftype = "Referral Type Code",
      selfharm_adm = "Self Harm Related Admission",
      sigfac = "Significant Facility Code",
      spec = "Specialty Classificat. 1/4/97 Code",
      submis_adm = "Substance Misuse Related Admission",
      cost_total_net = "Total Net Costs",
      location = "Treatment Location Code",
      hbtreatcode = "Treatment NHS Board Code - current"
    )

  return(extract_outpatients)
}
