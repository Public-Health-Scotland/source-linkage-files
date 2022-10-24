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
library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(lubridate)
library(createslf)


# Specify year
year <- check_year_format("1920")


## Load Lookups------------------------------------------

# Read code lookup
readcode_lookup <- readr::read_rds(get_readcode_lookup_path()) %>%
  dplyr::rename(
    readcode = "ReadCode",
    description = "Description"
  )

# OOH cost lookup
ooh_cost_lookup <- readr::read_rds(get_gp_ooh_costs_path()) %>%
  dplyr::rename(
    hbtreatcode = TreatmentNHSBoardCode
  )

# Diagnosis Data ---------------------------------

## Load extract file
diagnosis_extract <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-d"),
  col_types = cols(
    # All columns are character type
    .default = col_character()
  )
) %>%
  # rename variables
  dplyr::rename(
    guid = `GUID`,
    readcode = `Diagnosis Code`,
    description = `Diagnosis Description`
  ) %>%
  drop_na(readcode) %>%
  dplyr::distinct()


## Deal with Read Codes

diagnosis_readcodes <- diagnosis_extract %>%
  dplyr::mutate(
    # Replace question marks with dot
    readcode = str_replace_all(readcode, "\\?", "\\."),
    # Pad with dots up to 5 charaters
    readcode = str_pad(readcode, 5, "right", ".")
  ) %>%
  # Join diagnosis to readcode lookup
  # Identify diagnosis descriptions which match the readcode lookup
<<<<<<< HEAD
  left_join(
    readcode_lookup %>%
      mutate(full_match_1 = 1L),
    by = c("readcode", "description")
  ) %>%
  # match on true description from readcode lookup
  left_join(
    readcode_lookup %>%
      rename(true_description = description),
=======
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::mutate(full_match_1 = 1L),
    by = c("readcode", "description")
  ) %>%
  # match on true description from readcode lookup
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::rename(true_description = description),
>>>>>>> 19db6531 (Don't require loading dplyr)
    by = c("readcode")
  ) %>%
  # replace description with true description from readcode lookup if this is different
  dplyr::mutate(description = dplyr::if_else(is.na(full_match_1) & !is.na(true_description),
    true_description, description
  )) %>%
  # Join to readcode lookup again to check
<<<<<<< HEAD
  left_join(
    readcode_lookup %>%
      mutate(full_match_2 = 1L),
=======
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::mutate(full_match_2 = 1L),
>>>>>>> 19db6531 (Don't require loading dplyr)
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
<<<<<<< HEAD
  left_join(
    readcode_lookup %>%
      mutate(full_match_final = 1L),
=======
  dplyr::left_join(
    readcode_lookup %>%
      dplyr::mutate(full_match_final = 1L),
>>>>>>> 19db6531 (Don't require loading dplyr)
    by = c("readcode", "description")
  )

# See how the code above performed
diagnosis_readcodes %>%
  dplyr::count(full_match_1, full_match_2, full_match_final) %>%
  print()

# Check any readcodes which are still not matching the lookup
readcodes_not_matched <- diagnosis_readcodes %>%
  dplyr::filter(is.na(full_match_final)) %>%
  dplyr::count(readcode, description, sort = TRUE)

print(readcodes_not_matched)

# Give an error if any new 'bad' readcodes come up.
unrecognised_but_ok_codes <- c("@1JX.", "@1JXz", "@43jS", "@65PW", "@8CA.", "@8CAK", "@A795")

new_bad_codes <- readcodes_not_matched %>% dplyr::filter(!(readcode %in% unrecognised_but_ok_codes))

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
    readcode_level = str_locate(readcode, "\\.")[, "start"],
    readcode_level = replace_na(readcode_level, 6)
  ) %>%
  dtplyr::lazy_dt() %>%
  dplyr::group_by(guid) %>%
  # Sort so that the 'more specific' readcodes are preferred
  dplyr::arrange(desc(readcode_level)) %>%
  dplyr::mutate(diag_n = dplyr::row_number()) %>%
  dplyr::ungroup() %>%
  dplyr::select(-readcode_level) %>%
  # restructure data
  pivot_wider(
    names_from = diag_n,
    values_from = c(readcode, description),
    names_glue = "{.value}_{diag_n}"
  ) %>%
  dplyr::select(
    guid,
    # Use any of in case we have fewer than 6 diagnoses
    any_of(c(
      "diag_1",
      "diag_2",
      "diag_3",
      "diag_4",
      "diag_5",
      "diag_6"
    ))
  ) %>%
  as_tibble()

rm(diagnosis_extract, diagnosis_readcodes)

# Outcomes Data ---------------------------------

## Load extract file
outcomes_extract <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-o"),
  col_types = cols(
    # All columns are character type
    .default = col_character()
  )
) %>%
  # rename variables
  dplyr::rename(
    guid = `GUID`,
    outcome = `Case Outcome`
  ) %>%
  # Remove blank outcomes
  dplyr::filter(outcome != "") %>%
  dplyr::distinct()

## Data Cleaning
outcomes_clean <- outcomes_extract %>%
  dtplyr::lazy_dt() %>%
  # Recode outcome
  dplyr::mutate(
    outcome = recode(outcome,
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
  pivot_wider(
    names_from = outcome_n,
    names_prefix = "outcome_",
    values_from = outcome
  ) %>%
  dplyr::select(
    guid,
    any_of(c(
      "outcome_1",
      "outcome_2",
      "outcome_3",
      "outcome_4"
    ))
  ) %>%
  as_tibble()

rm(outcomes_extract)

# Consultations Data---------------------------------

# Read consultations data
consultations_file <- read_csv(
  file = get_boxi_extract_path(year, "GP_OoH-c"),
  col_types = cols(
    `UPI Number [C]` = col_character(),
    `Patient DoB Date [C]` = col_date(format = "%Y/%m/%d %T"),
    `Gender` = col_integer(),
    `Patient Postcode [C]` = col_character(),
    `Patient NHS Board Code 9 - current` = col_character(),
    `HSCP of Residence Code Current` = col_character(),
    `Patient Data Zone 2011` = col_character(),
    `Practice Code` = col_character(),
    `Practice NHS Board Code 9 - current` = col_character(),
    `GUID` = col_character(),
    `Consultation Recorded` = col_factor(levels = c("Y", "N")),
    `Consultation Start Date Time` = col_datetime(format = "%Y/%m/%d %H:%M:%S"),
    `Consultation End Date Time` = col_datetime(format = "%Y/%m/%d %H:%M:%S"),
    `Treatment Location Code` = col_character(),
    `Treatment Location Description` = col_character(),
    `Treatment NHS Board Code 9` = col_character(),
    `KIS Accessed` = col_factor(levels = c("Y", "N")),
    `Referral Source` = col_character(),
    `Consultation Type` = col_character(),
    `Consultation Type Unmapped` = col_character()
  )
) %>%
  # rename variables
  dplyr::rename(
    chi = `UPI Number [C]`,
    dob = `Patient DoB Date [C]`,
    gender = `Gender`,
    postcode = `Patient Postcode [C]`,
    hbrescode = `Patient NHS Board Code 9 - current`,
    hscp = `HSCP of Residence Code Current`,
    datazone = `Patient Data Zone 2011`,
    gpprac = `Practice Code`,
    guid = `GUID`,
    attendance_status = `Consultation Recorded`,
    record_keydate1 = `Consultation Start Date Time`,
    record_keydate2 = `Consultation End Date Time`,
    location = `Treatment Location Code`,
    location_description = `Treatment Location Description`,
    hbtreatcode = `Treatment NHS Board Code 9`,
    kis_accessed = `KIS Accessed`,
    refsource = `Referral Source`,
    smrtype = `Consultation Type`,
    conc_type_unmapped = `Consultation Type Unmapped`
  ) %>%
  dplyr::distinct()


## Data Cleaning

consultations_clean <- consultations_file %>%
  dtplyr::lazy_dt() %>%
  # Restore CHI leading zero
  dplyr::mutate(chi = phsmethods::chi_pad(chi)) %>%
  # Filter missing / bad CHI numbers
  dplyr::filter(phsmethods::chi_check(chi) == "Valid CHI") %>%
  # Some episodes are wrongly included in the BOXI extract
  # Filter to episodes with any time in the given financial year.
  dplyr::filter(
    is_date_in_year(record_keydate1, year) | is_date_in_year(record_keydate2, year)
  ) %>%
  # TODO - WIP James to here: I was looking at doing the merge overlapping episodes bit.
  dplyr::group_by(chi) %>%
  dplyr::arrange(chi, record_keydate1, record_keydate2) %>%
  dplyr::mutate(episode_counter = replace_na(record_keydate1 > lag(record_keydate2), TRUE) %>%
    cumsum()) %>%
  dplyr::ungroup() %>%
  as_tibble() %>%
  View()

# Where it's a duplicate except for an overlapping time flag it.
dplyr::mutate(to_merge = dplyr::if_else(overlap == 1 & duplicate == 1, 1, 0)) %>%
  # Repeat in the other direction so both records are flagged to be merged.
  #### CHECK HERE #### Is lead the right thing to do here in R to go the opposite direction?
  dplyr::mutate(to_merge = dplyr::if_else(
    guid == lead(guid) & chi == lead(chi) & record_keydate2 > record_keydate1 &
      smrtype == lead(smrtype) & location == lead(location), 1, to_merge
  )) %>%
  # Create counters for unique consultations.
  dplyr::arrange(guid, chi, record_keydate1, record_keydate2) %>%
  dplyr::group_by(chi, guid) %>%
  dplyr::mutate(
    counter = as.double(dplyr::row_number())
  ) %>%
  # If we've identified them as duplicates needing merged set the counter to indicate this.
  dplyr::mutate(counter = dplyr::if_else(to_merge == 1, 0, counter)) %>%
  dplyr::ungroup() %>%
  # Aggregate data
  dplyr::group_by(
    guid,
    chi,
    attendance_status,
    hbtreatcode,
    location,
    location_description,
    kis_accessed,
    refsource,
    smrtype,
    counter
  ) %>%
  dplyr::summarise(
    hbrescode = last(hbrescode),
    datazone = last(datazone),
    hscp = last(hscp),
    dob = last(dob),
    gender = last(gender),
    postcode = last(postcode),
    gpprac = last(gpprac),
    record_keydate1 = min(record_keydate1),
    record_keydate2 = max(record_keydate2)
  ) %>%
  dplyr::ungroup()


# Join data ---------------------------------

matched_data <- consultations_clean %>%
  dplyr::left_join(diagnosis_clean, by = "guid") %>%
  dplyr::left_join(outcomes_clean, by = "guid")

# Costs ---------------------------------

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
    )
  ) %>%
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # split time from date
  dplyr::mutate(
    key_time1 = hms::as_hms(substr(record_keydate1, 12, 19)),
    key_time2 = hms::as_hms(substr(record_keydate2, 12, 19)),
    record_keydate1 = substr(record_keydate1, 1, 10),
    record_keydate2 = substr(record_keydate2, 1, 10)
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
    year,
    recid,
    smrtype,
    record_keydate1,
    record_keydate2,
    key_time1,
    key_time2,
    chi,
    gender,
    dob,
    age,
    gpprac,
    postcode,
    hbrescode,
    datazone,
    hscp,
    hbtreatcode,
    location,
    attendance_status,
    kis_Accessed,
    refsource,
    contains("diag"),
    contains("ooh_outcome"),
    cost_total_net,
    apr_cost,
    may_cost,
    jun_cost,
    jul_cost,
    aug_cost,
    sep_cost,
    oct_cost,
    nov_cost,
    dec_cost,
    jan_cost,
    feb_cost,
    mar_cost,
    ooh_CC
  )

# End of Script #
