#' Read LTC IT extract
#'
#' @return csv data file
#' @export
#'
read_lookup_ltc <- function() {

  # Read data------------------------------------------------
  ltc_file <- readr::read_csv(
    file = get_it_ltc_path(),
    col_type = cols(
      "PATIENT_UPI [C]" = col_character(),
      "PATIENT_POSTCODE [C]" = col_character(),
      "ARTHRITIS_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "ASTHMA_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "ATRIAL_FIB_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "CANCER_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "CEREBROVASC_DIS_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "CHRON_LIVER_DIS_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "COPD_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "DEMENTIA_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "DIABETES_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "EPILEPSY_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "HEART_DISEASE_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "HEART_FAILURE_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "MULT_SCLEROSIS_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "PARKINSONS_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "RENAL_FAILURE_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "CONGENITAL_PROB_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "BLOOD_AND_BFO_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "OTH_DIS_END_MET_DIAG_DATE" = col_date(format = "%d-%m-%Y"),
      "OTH_DIS_DIG_SYS_DIAG_DATE" = col_date(format = "%d-%m-%Y")
    )
  ) %>%
    # Rename variables
    dplyr::rename(
      chi = "PATIENT_UPI [C]",
      postcode = "PATIENT_POSTCODE [C]",
      arth_date = "ARTHRITIS_DIAG_DATE",
      asthma_date = "ASTHMA_DIAG_DATE",
      atrialfib_date = "ATRIAL_FIB_DIAG_DATE",
      cancer_date = "CANCER_DIAG_DATE",
      cvd_date = "CEREBROVASC_DIS_DIAG_DATE",
      liver_date = "CHRON_LIVER_DIS_DIAG_DATE",
      copd_date = "COPD_DIAG_DATE",
      dementia_date = "DEMENTIA_DIAG_DATE",
      diabetes_date = "DIABETES_DIAG_DATE",
      epilepsy_date = "EPILEPSY_DIAG_DATE",
      chd_date = "HEART_DISEASE_DIAG_DATE",
      hefailure_date = "HEART_FAILURE_DIAG_DATE",
      ms_date = "MULT_SCLEROSIS_DIAG_DATE",
      parkinsons_date = "PARKINSONS_DIAG_DATE",
      refailure_date = "RENAL_FAILURE_DIAG_DATE",
      congen_date = "CONGENITAL_PROB_DIAG_DATE",
      bloodbfo_date = "BLOOD_AND_BFO_DIAG_DATE",
      endomet_date = "OTH_DIS_END_MET_DIAG_DATE",
      digestive_date = "OTH_DIS_DIG_SYS_DIAG_DATE"
    )

  chi_check <- ltc_file %>%
    dplyr::pull(.data$chi) %>%
    phsmethods::chi_check()

  if (!all(chi_check %in% c("Valid CHI", "Missing (Blank)", "Missing (NA)"))) {
    stop("There were bad CHI numbers in the LTC file")
  }


  return(ltc_file)
}
