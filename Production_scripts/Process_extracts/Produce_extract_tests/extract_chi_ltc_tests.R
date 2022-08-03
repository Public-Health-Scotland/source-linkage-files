####################################################
# Name of file - extract_chi_ltc_tests.R
# Original Authors - Bateman McBride
# Original Date - August 2022
# Written/run on - RStudio Server
# Version of R - 3.6.1
# Description - Produce tests for source linkage files:
#               LTC file received from IT.
#####################################################

year <- "1920"

new_data <- haven::read_sav(get_ltcs_path(year))

# Find and flag any duplicate chis and chi/postcode combinations
duplicates <- new_data %>%
  dtplyr::lazy_dt() %>%
  dplyr::group_by(chi) %>%
  dplyr::mutate(duplicate_chi = dplyr::n() > 1) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(chi, postcode) %>%
  dplyr::mutate(duplicate_chi_postcode = dplyr::n() > 1) %>%
  dplyr::ungroup() %>%
  dplyr::summarise(dplyr::across(c("duplicate_chi", "duplicate_chi_postcode"), sum)) %>%
  dplyr::ungroup() %>%
  tibble::as_tibble() %>%
  tidyr::pivot_longer(
    cols = tidyselect::everything(),
    names_to = "measure",
    values_to = "value"
  )

# Flag when a person has an LTC but no diagnosis date
valid_dates <- new_data %>%
  dplyr::mutate(
    arth_valid = (arth > 0 & !is.na(arth_date)),
    asthma_valid = (asthma > 0 & !is.na(asthma_date)),
    atrialfib_valid = (atrialfib > 0 & !is.na(atrialfib_date)),
    cancer_valid = (cancer > 0 & !is.na(cancer_date)),
    cvd_valid = (cvd > 0 & !is.na(cvd_date)),
    liver_valid = (liver > 0 & !is.na(liver_date)),
    copd_valid = (copd > 0 & !is.na(copd_date)),
    dementia_valid = (dementia > 0 & !is.na(dementia_date)),
    diabetes_valid = (diabetes > 0 & !is.na(diabetes_date)),
    epilepsy_valid = (epilepsy > 0 & !is.na(epilepsy_date)),
    chd_valid = (chd > 0 & !is.na(chd_date)),
    hefailure_valid = (hefailure > 0 & !is.na(hefailure_date)),
    ms_valid = (ms > 0 & !is.na(ms_date)),
    parkinsons_valid = (parkinsons > 0 & !is.na(parkinsons_date)),
    refailure_valid = (refailure > 0 & !is.na(refailure_date)),
    congen_valid = (congen > 0 & !is.na(congen_date)),
    bloodbfo_valid = (bloodbfo > 0 & !is.na(bloodbfo_date)),
    endomet_valid = (endomet > 0 & !is.na(endomet_date)),
    digestive_valid = (digestive > 0 & !is.na(digestive_date))
  ) %>%
  dplyr::summarise(
    dplyr::across(dplyr::contains("valid"), ~ sum(.x, na.rm = TRUE)),
    dplyr::across(c(arth:digestive), sum, na.rm = TRUE)
  ) %>%
  dplyr::mutate(
    arth_invalid = arth - arth_valid,
    asthma_invalid = asthma - asthma_valid,
    atrialfib_invalid = atrialfib - atrialfib_valid,
    cancer_invalid = cancer - cancer_valid,
    cvd_invalid = cvd - cvd_valid,
    liver_invalid = liver - liver_valid,
    copd_invalid = copd - copd_valid,
    dementia_invalid = dementia - dementia_valid,
    diabetes_invalid = diabetes - diabetes_valid,
    epilepsy_invalid = epilepsy - epilepsy_valid,
    chd_invalid = chd - chd_valid,
    hefailure_invalid = hefailure - hefailure_valid,
    ms_invalid = ms - ms_valid,
    parkinsons_invalid = parkinsons - parkinsons_valid,
    refailure_invalid = refailure - refailure_valid,
    congen_invalid = congen - congen_valid,
    bloodbfo_invalid = bloodbfo - bloodbfo_valid,
    endomet_invalid = endomet - endomet_valid,
    digestive_invalid = digestive - digestive_valid
  ) %>%
  tidyr::pivot_longer(
    cols = tidyselect::everything(),
    names_to = "measure",
    values_to = "value"
  )

# Put together for final output
comparison <- dplyr::bind_rows(duplicates, valid_dates)

# Produce Outfile----------------------------------------

# Save test comparisons as an excel workbook
write_tests_xlsx(comparison, "chi_ltc_extract")
