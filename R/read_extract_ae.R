#' Read A&E extract
#'
#' @inherit read_extract_acute
#'
#' @export
#'
read_extract_ae <- function(
  year,
  file_path = get_boxi_extract_path(year = year, type = "ae")
) {
  extract_ae <- read_file(file_path,
    col_type = readr::cols(
      "Arrival Date" = readr::col_date(format = "%Y/%m/%d %T"),
      "DAT Date" = readr::col_date(format = "%Y/%m/%d %T"),
      "anon_chi" = readr::col_character(),
      "Pat Date Of Birth [C]" = readr::col_date(format = "%Y/%m/%d %T"),
      "Pat Gender Code" = readr::col_double(),
      "NHS Board of Residence Code - current" = readr::col_character(),
      "Treatment NHS Board Code - current" = readr::col_character(),
      "Treatment Location Code" = readr::col_character(),
      "GP Practice Code" = readr::col_character(),
      "Council Area Code" = readr::col_character(),
      "Postcode (epi) [C]" = readr::col_character(),
      "Postcode (CHI) [C]" = readr::col_character(),
      "HSCP of Residence Code - current" = readr::col_character(),
      "Arrival Time" = readr::col_time(""),
      "DAT Time" = readr::col_time(""),
      "Arrival Mode Code" = readr::col_character(),
      "Referral Source Code" = readr::col_character(),
      "Attendance Category Code" = readr::col_character(),
      "Discharge Destination Code" = readr::col_character(),
      "Patient Flow Code" = readr::col_double(),
      "Place of Incident Code" = readr::col_character(),
      "Reason for Wait Code" = readr::col_character(),
      "Disease 1 Code" = readr::col_character(),
      "Disease 2 Code" = readr::col_character(),
      "Disease 3 Code" = readr::col_character(),
      "Bodily Location Of Injury Code" = readr::col_character(),
      "Alcohol Involved Code" = readr::col_character(),
      "Alcohol Related Admission" = readr::col_character(),
      "Substance Misuse Related Admission" = readr::col_character(),
      "Falls Related Admission" = readr::col_character(),
      "Self Harm Related Admission" = readr::col_character(),
      "Total Net Costs" = readr::col_double(),
      "Age at Midpoint of Financial Year" = readr::col_double(),
      "Case Reference Number" = readr::col_character(),
      "Significant Facility Code" = readr::col_character(),
      "Community Hospital Flag" = readr::col_character(),
    )
  ) %>%
    # rename variables
    dplyr::rename(
      record_keydate1 = "Arrival Date",
      record_keydate2 = "DAT Date",
      dob = "Pat Date Of Birth [C]",
      postcode_epi = "Postcode (epi) [C]",
      postcode_chi = "Postcode (CHI) [C]",
      age = "Age at Midpoint of Financial Year",
      ae_alcohol = "Alcohol Involved Code",
      alcohol_adm = "Alcohol Related Admission",
      ae_arrivalmode = "Arrival Mode Code",
      keytime1 = "Arrival Time",
      ae_attendcat = "Attendance Category Code",
      ae_bodyloc = "Bodily Location Of Injury Code",
      lca = "Council Area Code",
      ae_disdest = "Discharge Destination Code",
      keytime2 = "DAT Time",
      diag1 = "Disease 1 Code",
      diag2 = "Disease 2 Code",
      diag3 = "Disease 3 Code",
      falls_adm = "Falls Related Admission",
      gpprac = "GP Practice Code",
      hscp = "HSCP of Residence Code - current",
      hbrescode = "NHS Board of Residence Code - current",
      hbtreatcode = "Treatment NHS Board Code - current",
      anon_chi = "anon_chi",
      gender = "Pat Gender Code",
      ae_patflow = "Patient Flow Code",
      ae_placeinc = "Place of Incident Code",
      ae_reasonwait = "Reason for Wait Code",
      refsource = "Referral Source Code",
      selfharm_adm = "Self Harm Related Admission",
      submis_adm = "Substance Misuse Related Admission",
      sigfac = "Significant Facility Code",
      cost_total_net = "Total Net Costs",
      location = "Treatment Location Code",
      case_ref_number = "Case Reference Number",
      commhosp = "Community Hospital Flag"
    )

  return(extract_ae)
}
