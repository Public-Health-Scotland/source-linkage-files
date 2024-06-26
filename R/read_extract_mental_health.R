#' Read Mental Health extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_mental_health <- function(
    year,
    file_path = get_boxi_extract_path(year = year, type = "mh")) {
  # Read BOXI extract
  extract_mental_health <- read_file(file_path,
    col_types = readr::cols_only(
      "Costs Financial Year (04)" = readr::col_double(),
      "Costs Financial Month Number (04)" = readr::col_double(),
      "Date of Admission(04)" = readr::col_date(format = "%Y/%m/%d %T"),
      "Date of Discharge(04)" = readr::col_date(format = "%Y/%m/%d %T"),
      "anon_chi" = readr::col_character(),
      "Pat Gender Code" = readr::col_integer(),
      "Pat Date Of Birth [C]" = readr::col_date(format = "%Y/%m/%d %T"),
      "Practice Location Code" = readr::col_character(),
      "Practice NHS Board Code - current" = readr::col_character(),
      "Geo Postcode [C]" = readr::col_character(),
      "NHS Board of Residence Code - current" = readr::col_character(),
      "Geo Council Area Code" = readr::col_character(),
      "Geo HSCP of Residence Code - current" = readr::col_character(),
      "Geo Data Zone 2011" = readr::col_character(),
      "Treatment Location Code" = readr::col_character(),
      "Treatment NHS Board Code - current" = readr::col_character(),
      "Occupied Bed Days (04)" = readr::col_double(),
      "Specialty Classificat. 1/4/97 Code" = readr::col_character(),
      "Significant Facility Code" = readr::col_character(),
      "Lead Consultant/HCP Code" = readr::col_character(),
      "Management of Patient Code" = readr::col_character(),
      "Patient Category Code" = readr::col_character(),
      "Admission Type Code" = readr::col_character(),
      "Admitted Trans From Code" = readr::col_character(),
      "Location Admitted Trans From Code" = readr::col_character(),
      "Discharge Type Code" = readr::col_character(),
      "Discharge Trans To Code" = readr::col_character(),
      "Location Discharged Trans To Code" = readr::col_character(),
      "Diagnosis 1 Code (6 char)" = readr::col_character(),
      "Diagnosis 2 Code (6 char)" = readr::col_character(),
      "Diagnosis 3 Code (6 char)" = readr::col_character(),
      "Diagnosis 4 Code (6 char)" = readr::col_character(),
      "Diagnosis 5 Code (6 char)" = readr::col_character(),
      "Diagnosis 6 Code (6 char)" = readr::col_character(),
      "Status on Admission Code" = readr::col_integer(),
      "Admission Diagnosis 1 Code (6 char)" = readr::col_character(),
      "Admission Diagnosis 2 Code (6 char)" = readr::col_character(),
      "Admission Diagnosis 3 Code (6 char)" = readr::col_character(),
      "Admission Diagnosis 4 Code (6 char)" = readr::col_character(),
      "Age at Midpoint of Financial Year (04)" = readr::col_integer(),
      "Continuous Inpatient Journey Marker (04)" = readr::col_integer(),
      "CIJ Planned Admission Code (04)" = readr::col_integer(),
      "CIJ Inpatient Day Case Identifier Code (04)" = readr::col_character(),
      "CIJ Type of Admission Code (04)" = readr::col_character(),
      "CIJ Admission Specialty Code (04)" = readr::col_character(),
      "CIJ Discharge Specialty Code (04)" = readr::col_character(),
      "CIJ Start Date (04)" = readr::col_date(format = "%Y/%m/%d %T"),
      "CIJ End Date (04)" = readr::col_date(format = "%Y/%m/%d %T"),
      "Total Net Costs (04)" = readr::col_double(),
      "Alcohol Related Admission (04)" = readr::col_factor(levels = c("Y", "N")),
      "Substance Misuse Related Admission (04)" = readr::col_factor(levels = c("Y", "N")),
      "Falls Related Admission (04)" = readr::col_factor(levels = c("Y", "N")),
      "Self Harm Related Admission (04)" = readr::col_factor(levels = c("Y", "N")),
      "Duplicate Record Flag (04)" = readr::col_factor(levels = c("Y", "N")),
      "NHS Hospital Flag (04)" = readr::col_factor(levels = c("Y", "N")),
      "Community Hospital Flag (04)" = readr::col_factor(levels = c("Y", "N")),
      "Unique Record Identifier" = readr::col_character()
    )
  ) %>%
    # rename variables
    dplyr::rename(
      costsfy = "Costs Financial Year (04)",
      costmonthnum = "Costs Financial Month Number (04)",
      record_keydate1 = "Date of Admission(04)",
      record_keydate2 = "Date of Discharge(04)",
      anon_chi = "anon_chi",
      gender = "Pat Gender Code",
      dob = "Pat Date Of Birth [C]",
      gpprac = "Practice Location Code",
      hbpraccode = "Practice NHS Board Code - current",
      postcode = "Geo Postcode [C]",
      hbrescode = "NHS Board of Residence Code - current",
      lca = "Geo Council Area Code",
      hscp = "Geo HSCP of Residence Code - current",
      datazone2011 = "Geo Data Zone 2011",
      location = "Treatment Location Code",
      hbtreatcode = "Treatment NHS Board Code - current",
      yearstay = "Occupied Bed Days (04)",
      spec = "Specialty Classificat. 1/4/97 Code",
      sigfac = "Significant Facility Code",
      conc = "Lead Consultant/HCP Code",
      mpat = "Management of Patient Code",
      cat = "Patient Category Code",
      tadm = "Admission Type Code",
      adtf = "Admitted Trans From Code",
      admloc = "Location Admitted Trans From Code",
      disch = "Discharge Type Code",
      dischto = "Discharge Trans To Code",
      dischloc = "Location Discharged Trans To Code",
      diag1 = "Diagnosis 1 Code (6 char)",
      diag2 = "Diagnosis 2 Code (6 char)",
      diag3 = "Diagnosis 3 Code (6 char)",
      diag4 = "Diagnosis 4 Code (6 char)",
      diag5 = "Diagnosis 5 Code (6 char)",
      diag6 = "Diagnosis 6 Code (6 char)",
      stadm = "Status on Admission Code",
      adcon1 = "Admission Diagnosis 1 Code (6 char)",
      adcon2 = "Admission Diagnosis 2 Code (6 char)",
      adcon3 = "Admission Diagnosis 3 Code (6 char)",
      adcon4 = "Admission Diagnosis 4 Code (6 char)",
      age = "Age at Midpoint of Financial Year (04)",
      cij_marker = "Continuous Inpatient Journey Marker (04)",
      cij_pattype_code = "CIJ Planned Admission Code (04)",
      cij_inpatient = "CIJ Inpatient Day Case Identifier Code (04)",
      cij_admtype = "CIJ Type of Admission Code (04)",
      cij_adm_spec = "CIJ Admission Specialty Code (04)",
      cij_dis_spec = "CIJ Discharge Specialty Code (04)",
      cij_start_date = "CIJ Start Date (04)",
      cij_end_date = "CIJ End Date (04)",
      cost_total_net = "Total Net Costs (04)",
      alcohol_adm = "Alcohol Related Admission (04)",
      submis_adm = "Substance Misuse Related Admission (04)",
      falls_adm = "Falls Related Admission (04)",
      selfharm_adm = "Self Harm Related Admission (04)",
      duplicate = "Duplicate Record Flag (04)",
      nhshosp = "NHS Hospital Flag (04)",
      commhosp = "Community Hospital Flag (04)",
      uri = "Unique Record Identifier"
    ) %>%
    # replace NA in cost_total_net by 0
    dplyr::mutate(
      cost_total_net = tidyr::replace_na(.data[["cost_total_net"]], 0.0)
    ) %>%
    slfhelper::get_chi()

  return(extract_mental_health)
}
