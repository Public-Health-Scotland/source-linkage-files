#' Read Outpatients extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for Acute
#' @export
#'
read_extract_outpatients <- function(year) {
  extract_outpatients_path <- get_boxi_extract_path(year = year, type = "Outpatient")

  # Read BOXI extract
  extract_outpatients <- readr::read_csv(extract_outpatients_path,
    col_type = cols(
      "Clinic Date Fin Year" = col_double(),
      "Clinic Date (00)" = col_date(format = "%Y/%m/%d %T"),
      "Episode Record Key (SMR00) [C]" = col_character(),
      "Pat UPI" = col_character(),
      "Pat Gender Code" = col_double(),
      "Pat Date Of Birth [C]" = col_date(format = "%Y/%m/%d %T"),
      "Practice Location Code" = col_character(),
      "Practice NHS Board Code - current" = col_character(),
      "Geo Postcode [C]" = col_character(),
      "NHS Board of Residence Code - current" = col_character(),
      "Geo Council Area Code" = col_character(),
      "Treatment Location Code" = col_character(),
      "Treatment NHS Board Code - current" = col_character(),
      "Operation 1A Code (4 char)" = col_character(),
      "Operation 1B Code (4 char)" = col_character(),
      "Date of Main Operation(00)" = col_date(format = "%Y/%m/%d %T"),
      "Operation 2A Code (4 char)" = col_character(),
      "Operation 2B Code (4 char)" = col_character(),
      "Date of Operation 2 (00)" = col_date(format = "%Y/%m/%d %T"),
      "Specialty Classificat. 1/4/97 Code" = col_character(),
      "Significant Facility Code" = col_character(),
      "Consultant/HCP Code" = col_character(),
      "Patient Category Code" = col_character(),
      "Referral Source Code" = col_character(),
      "Referral Type Code" = col_double(),
      "Clinic Type Code" = col_double(),
      "Clinic Attendance (Status) Code" = col_double(),
      "Age at Midpoint of Financial Year" = col_double(),
      "Alcohol Related Admission" = col_character(),
      "Substance Misuse Related Admission" = col_character(),
      "Falls Related Admission" = col_character(),
      "Self Harm Related Admission" = col_character(),
      "NHS Hospital Flag" = col_character(),
      "Community Hospital Flag" = col_character(),
      "Total Net Costs" = col_double()
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
