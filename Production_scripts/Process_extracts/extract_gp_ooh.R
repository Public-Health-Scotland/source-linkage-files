#####################################################
# Draft pre processing code for Gp Out of Hours
# Author: Jennifer Thom
# Date: April 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - GP-OoH-
#         # diagnosis-extract-.csv
#         # outcomes-extract-.csv
#         # consultations-extract-.csv
#
# Description - Preprocessing of GP out of hours raw BOXI file.
#              Tidy up file in line with SLF format
#              prior to processing.
#####################################################

# Load Packages
library(createslf)

# Specify year
year <- check_year_format("1920")


# Diagnosis Data ---------------------------------

# Read code lookup
readcode_lookup <- readr::read_rds(get_readcode_lookup_path()) %>%
  dplyr::rename(
    readcode = "ReadCode",
    description = "Description"
  )

# Load extract file
diagnosis_extract <- readr::read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-d"),
  col_types = readr::cols(
    # All columns are character type
    .default = readr::col_character()
  )
) %>%
  # rename variables
  dplyr::rename(
    guid = "GUID",
    readcode = "Diagnosis Code",
    description = "Diagnosis Description"
  ) %>%
  tidyr::drop_na(readcode) %>%
  dplyr::distinct()


## Deal with Read Codes

diagnosis_readcodes <- diagnosis_extract %>%
  dplyr::mutate(
    # Replace question marks with dot
    readcode = stringr::str_replace_all(readcode, "\\?", "\\."),
    # Pad with dots up to 5 charaters
    readcode = stringr::str_pad(readcode, 5, "right", ".")
  ) %>%
  # Join diagnosis to readcode lookup
  # Identify diagnosis descriptions which match the readcode lookup
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::mutate(full_match_1 = 1L),
    by = c("readcode", "description")
  ) %>%
  # match on true description from readcode lookup
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::rename(true_description = description),
    by = c("readcode")
  ) %>%
  # replace description with true description from readcode lookup if this is different
  dplyr::mutate(description = dplyr::if_else(is.na(full_match_1) & !is.na(true_description),
    true_description, description
  )) %>%
  # Join to readcode lookup again to check
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::mutate(full_match_2 = 1L),
    by = c("readcode", "description")
  ) %>%
  # Check the output for any dodgy Read codes and try and fix by adding exceptions
  dplyr::mutate(readcode = dplyr::if_else(is.na(full_match_2), dplyr::case_when(
    readcode == "Xa1m." ~ "S349",
    readcode == "Xa1mz" ~ "S349",
    readcode == "HO6.." ~ "H06..",
    readcode == "zV6.." ~ "ZV6..",
    TRUE ~ readcode
  ), readcode)) %>%
  # Join to readcode lookup again to check
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::mutate(full_match_final = 1L),
    by = c("readcode", "description")
  )

# See how the code above performed
diagnosis_readcodes %>%
  dplyr::count(full_match_1, full_match_2, full_match_final)

# Check any readcodes which are still not matching the lookup
readcodes_not_matched <- diagnosis_readcodes %>%
  dplyr::filter(is.na(full_match_final)) %>%
  dplyr::count(readcode, description, sort = TRUE)

readcodes_not_matched

# Give an error if any new 'bad' readcodes come up.
unrecognised_but_ok_codes <- c("@1JX.", "@1JXz", "@43jS", "@65PW", "@8CA.", "@8CAK", "@A795")

new_bad_codes <- readcodes_not_matched %>%
  dplyr::filter(!(readcode %in% unrecognised_but_ok_codes))

if (nrow(new_bad_codes) != 0) {
  cli::cli_abort(c("New unrecognised readcodes",
    "i" = "There {?is/are} {nrow(new_bad_codes)} new unrecognised readcode{?s} in the data.",
    " " = "Check the {cli::qty(nrow(new_bad_codes))} code{?s} then either fix, or add {?it/them} to the {.var unrecognised_but_ok_codes} vector",
    "",
    ">" = "New bad {cli::qty(nrow(new_bad_codes))} code{?s}: {new_bad_codes$readcode}"
  ))
}

rm(readcode_lookup, readcodes_not_matched, unrecognised_but_ok_codes, new_bad_codes)

## Data Cleaning

diagnosis_clean <- diagnosis_readcodes %>%
  dplyr::select(guid, readcode, description) %>%
  dplyr::mutate(
    readcode_level = stringr::str_locate(readcode, "\\.")[, "start"],
    readcode_level = tidyr::replace_na(readcode_level, 6)
  ) %>%
  dtplyr::lazy_dt() %>%
  dplyr::group_by(guid) %>%
  # Sort so that the 'more specific' readcodes are preferred
  dplyr::arrange(desc(readcode_level)) %>%
  dplyr::mutate(diag_n = dplyr::row_number()) %>%
  dplyr::ungroup() %>%
  dplyr::select(-readcode_level) %>%
  # restructure data
  tidyr::pivot_wider(
    names_from = diag_n,
    values_from = c(readcode, description),
    names_glue = "{.value}_{diag_n}"
  ) %>%
  dplyr::select(
    "guid",
    # Use any of in case we have fewer than 6 diagnoses
    tidyselect::any_of(c(
      "diag_1",
      "diag_2",
      "diag_3",
      "diag_4",
      "diag_5",
      "diag_6"
    ))
  ) %>%
  dplyr::as_tibble()

rm(diagnosis_extract, diagnosis_readcodes)

# Outcomes Data ---------------------------------

## Load extract file
outcomes_extract <- readr::read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-o"),
  col_types = readr::cols(
    # All columns are character type
    .default = readr::col_character()
  )
) %>%
  # rename variables
  dplyr::rename(
    guid = "GUID",
    outcome = "Case Outcome"
  ) %>%
  # Remove blank outcomes
  dplyr::filter(outcome != "") %>%
  dplyr::distinct()

## Data Cleaning
outcomes_clean <- outcomes_extract %>%
  dtplyr::lazy_dt() %>%
  # Recode outcome
  dplyr::mutate(
    outcome = dplyr::recode(outcome,
      "DEATH" = "00",
      "999/AMBULANCE" = "01",
      "EMERGENCY ADMISSION" = "02",
      "ADVISED TO CONTACT OWN GP SURGERY/GP TO CONTACT PATIENT" = "03",
      "TREATMENT COMPLETED AT OOH/DISCHARGED/NO FOLLOW-UP" = "98",
      "REFERRED TO A&E" = "21",
      "REFERRED TO CPN/DISTRICT NURSE/MIDWIFE" = "22",
      "REFERRED TO MIU" = "21",
      "REFERRED TO SOCIAL SERVICES" = "24",
      "OTHER HC REFERRAL/ADVISED TO CONTACT OTHER HCP (NON-EMERGENCY)" = "29",
      "OTHER" = "99"
    )
  ) %>%
  # Sort so we prefer 'lower' outcomes e.g. Death, over things like 'Other'
  dplyr::group_by(guid) %>%
  dplyr::arrange(outcome) %>%
  dplyr::mutate(outcome_n = dplyr::row_number()) %>%
  dplyr::ungroup() %>%
  # use row order to pivot outcomes
  tidyr::pivot_wider(
    names_from = outcome_n,
    names_prefix = "outcome_",
    values_from = outcome
  ) %>%
  dplyr::select(
    "guid",
    tidyselect::any_of(c(
      "outcome_1",
      "outcome_2",
      "outcome_3",
      "outcome_4"
    ))
  ) %>%
  dplyr::as_tibble()

rm(outcomes_extract)

# Consultations Data---------------------------------

# Read consultations data
consultations_file <- readr::read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-c"),
  col_types = readr::cols(
    "UPI Number [C]" = readr::col_character(),
    "Patient DoB Date [C]" = readr::col_date(format = "%Y/%m/%d %T"),
    "Gender" = readr::col_integer(),
    "Patient Postcode [C]" = readr::col_character(),
    "Patient NHS Board Code 9 - current" = readr::col_character(),
    "HSCP of Residence Code Current" = readr::col_character(),
    "Patient Data Zone 2011" = readr::col_character(),
    "Practice Code" = readr::col_character(),
    "Practice NHS Board Code 9 - current" = readr::col_character(),
    "GUID" = readr::col_character(),
    "Consultation Recorded" = readr::col_factor(levels = c("Y", "N")),
    "Consultation Start Date Time" = readr::col_datetime(format = "%Y/%m/%d %H:%M:%S"),
    "Consultation End Date Time" = readr::col_datetime(format = "%Y/%m/%d %H:%M:%S"),
    "Treatment Location Code" = readr::col_character(),
    "Treatment Location Description" = readr::col_character(),
    "Treatment NHS Board Code 9" = readr::col_character(),
    "KIS Accessed" = readr::col_factor(levels = c("Y", "N")),
    "Referral Source" = readr::col_character(),
    "Consultation Type" = readr::col_character(),
    "Consultation Type Unmapped" = readr::col_character()
  )
) %>%
  # rename variables
  dplyr::rename(
    chi = "UPI Number [C]",
    dob = "Patient DoB Date [C]",
    gender = "Gender",
    postcode = "Patient Postcode [C]",
    hbrescode = "Patient NHS Board Code 9 - current",
    hscp = "HSCP of Residence Code Current",
    datazone = "Patient Data Zone 2011",
    gpprac = "Practice Code",
    guid = "GUID",
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
  # Restore CHI leading zero
  dplyr::mutate(chi = phsmethods::chi_pad(chi)) %>%
  dplyr::distinct()


## Data Cleaning

fnc_consulation_types <- c(
  "ED APPOINTMENT",
  "ED TELEPHONE ASSESSMENT",
  "ED TO BOOK",
  "ED TELEPHONE / REMOTE CONSULTATION",
  "MIU APPOINTMENT",
  "MIU TELEPHONE ASSESSMENT",
  "MIU TO BOOK",
  "MIU TELEPHONE / REMOTE CONSULTATION",
  "TELEPHONE ASSESSMENT",
  "TELEPHONE/VIRTUAL ASSESSMENT"
)

consultations_filtered <- consultations_file %>%
  dtplyr::lazy_dt() %>%
  # Filter missing / bad CHI numbers
  dplyr::filter(phsmethods::chi_check(chi) == "Valid CHI") %>%
  # Fix some times - if end before start, remove the time portion
  tidylog::mutate(
    bad_dates = record_keydate1 > record_keydate2,
    record_keydate1 = dplyr::if_else(bad_dates,
      lubridate::floor_date(record_keydate1, "day"),
      record_keydate1
    ),
    record_keydate2 = dplyr::if_else(bad_dates,
      lubridate::floor_date(record_keydate1, "day"),
      record_keydate2
    )
  ) %>%
  # Some episodes are wrongly included in the BOXI extract
  # Filter to episodes with any time in the given financial year.
  dplyr::filter(is_date_in_fyyear(year, record_keydate1, record_keydate2)) %>%
  # Filter out Flow navigation center data
  dplyr::filter(!(consultation_type_unmapped %in% fnc_consulation_types)) %>%
  dplyr::as_tibble()

rm(consultations_file)

consultations_covid <- consultations_filtered %>%
  dplyr::mutate(consultation_type = dplyr::if_else(is.na(consultation_type),
    dplyr::case_when(
      consultation_type_unmapped == "COVID19 ASSESSMENT" ~ consultation_type_unmapped,
      consultation_type_unmapped == "COVID19 ADVICE" ~ consultation_type_unmapped,
      consultation_type_unmapped %in% c("COVID19 HOME VISIT", "COVID19 OBSERVATION", "COVID19 VIDEO CALL", "COVID19 TEST") ~ "COVID19 OTHER"
    ),
    consultation_type
  ))

# Clean up some overlapping episodes
# Only merge if they look like duplicates other than the time,
# In which case take the earliest start and latest end.
consultations_clean <- consultations_covid %>%
  dtplyr::lazy_dt() %>%
  # Sort in reverse order so we can use coalesce which takes the first non-missing value
  dplyr::arrange(chi, guid, dplyr::desc(record_keydate1), dplyr::desc(record_keydate2)) %>%
  # This seems to be enough to identify a unique episode
  dplyr::group_by(chi, guid, consultation_type, location) %>%
  # Records will be merged if they don't look unique and there is overlap or no time between them
  dplyr::mutate(episode_counter = replace_na(record_keydate1 > lag(record_keydate2), TRUE) %>%
    cumsum()) %>%
  dplyr::group_by(chi, guid, consultation_type, location, episode_counter) %>%
  dplyr::summarise(
    record_keydate1 = min(record_keydate1),
    record_keydate2 = max(record_keydate2),
    dplyr::across(c(dplyr::everything(), -record_keydate1, -record_keydate2), dplyr::coalesce)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::as_tibble()

rm(consultations_filtered, consultations_covid)

# Join data ---------------------------------

matched_data <- consultations_clean %>%
  dplyr::left_join(diagnosis_clean, by = "guid") %>%
  dplyr::left_join(outcomes_clean, by = "guid")

rm(consultations_clean, diagnosis_clean, outcomes_clean)

# Costs ---------------------------------

# OOH cost lookup
ooh_cost_lookup <- readr::read_rds(get_gp_ooh_costs_path()) %>%
  dplyr::rename(
    hbtreatcode = TreatmentNHSBoardCode
  )

ooh_costs <- matched_data %>%
  dplyr::mutate(
    hbtreatcode = dplyr::case_when(
      # Recode Fife and Tayside so they match the cost lookup.
      hbtreatcode == "S08000018" ~ "S08000029",
      hbtreatcode == "S08000027" ~ "S08000030",
      # Recode Greater Glasgow & Clyde and Lanarkshire so they
      # match the costs lookup (2018 > 2019 HB codes).
      hbtreatcode == "S08000021" ~ "S08000031",
      hbtreatcode == "S08000023" ~ "S08000032",
      TRUE ~ hbtreatcode
    ),
    year = year
  ) %>%
  dplyr::arrange(hbtreatcode, year) %>%
  # Match to cost lookup
  dplyr::left_join(ooh_cost_lookup, by = c("hbtreatcode", "year")) %>%
  dplyr::rename(
    cost_total_net = cost_per_consultation
  ) %>%
  create_day_episode_costs(record_keydate1, cost_total_net)


# Final cleaning  ---------------------------------

ooh_clean <- ooh_costs %>%
  # rename outcomes
  dplyr::rename(
    ooh_outcome.1 = outcome.1,
    ooh_outcome.2 = outcome.2,
    ooh_outcome.3 = outcome.3,
    ooh_outcome.4 = outcome.4
  ) %>%
  dplyr::mutate(
    # Replace location unknown with blank. Should this be NA?
    location = dplyr::if_else(location == "UNKNOWN", "", location),
    recid = "OoH",
    smrtype = dplyr::case_when(
      smrtype == "DISTRICT NURSE" ~ "OOH-DN",
      smrtype == "DOCTOR ADVICE/NURSE ADVICE" ~ "OOH-Advice",
      smrtype == "HOME VISIT" ~ "OOH-HomeV",
      smrtype == "NHS 24 NURSE ADVICE" ~ "OOH-NHS24",
      smrtype == "PCEC/PCC" ~ "OOH-PCC",
      TRUE ~ "OOH-Other"
    ),
    kis_accessed = dplyr::case_when(
      kis_accessed == "Y" ~ 1,
      kis_accessed == "N" ~ 0,
      TRUE ~ 9
    ),
    gpprac = convert_eng_gpprac_to_dummy(gpprac)
  ) %>%
  # split time from date
  dplyr::mutate(
    key_time1 = hms::as_hms(stringr::str_sub(record_keydate1, 12L, 19L)),
    key_time2 = hms::as_hms(stringr::str_sub(record_keydate2, 12L, 19L)),
    record_keydate1 = stringr::str_sub(record_keydate1, 1L, 10L),
    record_keydate2 = stringr::str_sub(record_keydate2, 1L, 10L)
  )

# Keep the location descriptions as a lookup.
location_lookup <- ooh_clean %>%
  dplyr::group_by(location) %>%
  dplyr::summarise(
    location_description = dplyr::first(location_description)
  ) %>%
  dplyr::ungroup()

ooh_clean <- ooh_clean %>%
  dplyr::arrange(guid, chi) %>%
  # group for getting row order
  dplyr::group_by(guid, chi) %>%
  dplyr::mutate(
    row_order = dplyr::row_number(),
    ooh_cc = 0,
    ooh_cc = dplyr::case_when(
      ooh_cc == 0 & row_order == 1 | chi != lag(chi, default = dplyr::first(chi)) ~ 1,
      ooh_cc == 0 & guid != lag(guid) ~ lag(ooh_cc, default = dplyr::first(ooh_cc)) + 1,
      ooh_cc == 0 ~ lag(ooh_cc, default = dplyr::first(ooh_cc))
    )
  )


## Save Outfile -------------------------------------

outfile <- ooh_clean %>%
  dplyr::arrange(
    chi,
    record_keydate1,
    key_time1
  ) %>%
  dplyr::select(
    "year",
    "recid",
    "smrtype",
    "record_keydate1",
    "record_keydate2",
    "key_time1",
    "key_time2",
    "chi",
    "gender",
    "dob",
    "age",
    "gpprac",
    "postcode",
    "hbrescode",
    "datazone",
    "hscp",
    "hbtreatcode",
    "location",
    "attendance_status",
    "kis_Accessed",
    "refsource",
    tidyselect::contains("diag"),
    tidyselect::contains("ooh_outcome"),
    "cost_total_net",
    "apr_cost",
    "may_cost",
    "jun_cost",
    "jul_cost",
    "aug_cost",
    "sep_cost",
    "oct_cost",
    "nov_cost",
    "dec_cost",
    "jan_cost",
    "feb_cost",
    "mar_cost",
    "ooh_CC"
  )

# End of Script #
