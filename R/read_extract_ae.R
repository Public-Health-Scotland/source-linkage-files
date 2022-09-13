#' Read A&E extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for A&E
#' @export
#'
read_extract_ae <- function(year) {
  extract_ae_path <- get_boxi_extract_path(year = year, type = "AE")

extract_ae<- readr::read_csv(extract_ae_path,
  col_type = cols(
    `Arrival Date` = col_date(format = "%Y/%m/%d %T"),
    `DAT Date` = col_date(format = "%Y/%m/%d %T"),
    `Pat UPI [C]` = col_character(),
    `Pat Date Of Birth [C]` = col_date(format = "%Y/%m/%d %T"),
    `Pat Gender Code` = col_double(),
    `NHS Board of Residence Code - current` = col_character(),
    `Treatment NHS Board Code - current` = col_character(),
    `Treatment Location Code` = col_character(),
    `GP Practice Code` = col_character(),
    `Council Area Code` = col_character(),
    `Postcode (epi) [C]` = col_character(),
    `Postcode (CHI) [C]` = col_character(),
    `HSCP of Residence Code - current` = col_character(),
    `Arrival Time` = col_time(""),
    `DAT Time` = col_time(""),
    `Arrival Mode Code` = col_character(),
    `Referral Source Code` = col_character(),
    `Attendance Category Code` = col_character(),
    `Discharge Destination Code` = col_character(),
    `Patient Flow Code` = col_double(),
    `Place of Incident Code` = col_character(),
    `Reason for Wait Code` = col_character(),
    `Disease 1 Code` = col_character(),
    `Disease 2 Code` = col_character(),
    `Disease 3 Code` = col_character(),
    `Bodily Location Of Injury Code` = col_character(),
    `Alcohol Involved Code` = col_character(),
    `Alcohol Related Admission` = col_character(),
    `Substance Misuse Related Admission` = col_character(),
    `Falls Related Admission` = col_character(),
    `Self Harm Related Admission` = col_character(),
    `Total Net Costs` = col_double(),
    `Age at Midpoint of Financial Year` = col_double(),
    `Case Reference Number` = col_character(),
    `Significant Facility Code` = col_double()
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
    keyTime1 = "Arrival Time",
    ae_attendcat = "Attendance Category Code",
    ae_bodyloc = "Bodily Location Of Injury Code",
    lca = "Council Area Code",
    ae_disdest = "Discharge Destination Code",
    keyTime2 = "DAT Time",
    diag1 = "Disease 1 Code",
    diag2 = "Disease 2 Code",
    diag3 = "Disease 3 Code",
    falls_adm = "Falls Related Admission",
    gpprac = "GP Practice Code",
    hscp = "HSCP of Residence Code - current",
    hbrescode = "NHS Board of Residence Code - current",
    hbtreatcode = "Treatment NHS Board Code - current",
    chi = "Pat UPI [C]",
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
    case_ref_number = "Case Reference Number"
  )

return(extract_ae)

}
