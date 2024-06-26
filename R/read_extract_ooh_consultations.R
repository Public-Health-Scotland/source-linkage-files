#' Read GP OOH Consultations extract
#'
#' @inherit read_extract_acute
#'
#' @return a [tibble][tibble::tibble-package] with OOH Consultations extract data
read_extract_ooh_consultations <- function(
    year,
    file_path = get_boxi_extract_path(year = year, type = "gp_ooh-c")) {
  # Read consultations data
  consultations_extract <- read_file(file_path,
    col_types = readr::cols(
      "Patient DoB Date [C]" = readr::col_date(
        format = "%Y/%m/%d %T"
      ),
      "Gender" = readr::col_integer(),
      "Consultation Recorded" = readr::col_character(),
      "Consultation Start Date Time" = readr::col_datetime(
        format = "%Y/%m/%d %T"
      ),
      "Consultation End Date Time" = readr::col_datetime(
        format = "%Y/%m/%d %T"
      ),
      "KIS Accessed" = readr::col_factor(levels = c("Y", "N")),
      # All other columns are character type
      .default = readr::col_character()
    )
  ) %>%
    dplyr::select(!"Practice NHS Board Code 9 - current") %>%
    # rename variables
    dplyr::rename(
      anon_chi = "anon_chi",
      dob = "Patient DoB Date [C]",
      gender = "Gender",
      postcode = "Patient Postcode [C]",
      hbrescode = "Patient NHS Board Code 9 - current",
      hscp = "HSCP of Residence Code Current",
      datazone2011 = "Patient Data Zone 2011",
      gpprac = "Practice Code",
      ooh_case_id = "GUID",
      attendance_status = "Consultation Recorded",
      record_keydate1 = "Consultation Start Date Time",
      record_keydate2 = "Consultation End Date Time",
      location = "Treatment Location Code",
      location_description = "Treatment Location Description",
      hbtreatcode = "Treatment NHS Board Code 9",
      kis_accessed = "KIS Accessed",
      refsource = "Referral Source",
      consultation_type = "Consultation Type",
      consultation_type_unmapped = "Consultation Type Unmapped"
    ) %>%
    slfhelper::get_chi() %>%
    # Restore CHI leading zero
    dplyr::mutate(chi = phsmethods::chi_pad(.data$chi)) %>%
    dplyr::distinct()


  return(consultations_extract)
}
