library(createslf)
library(readr)
library(dplyr)
library(tidyr)

year <- "1920"

# Read the data and clean the variable names ------------------------------

homelessness_extract <- read_csv(extract_path(year = year, type = "Homelessness"),
  col_types = cols(
    `Assessment Decision Date` = col_date(format = boxi_date_format()),
    `Case Closed Date` = col_date(format = boxi_date_format()),
    `Sending Local Authority Code 9` = col_character(),
    `Client Unique Identifier` = col_character(),
    `UPI Number [C]` = col_character(),
    `Client DoB Date [C]` = col_date(format = boxi_date_format()),
    `Age at Assessment Decision Date` = col_integer(),
    `Gender Code` = col_integer(),
    `Client Postcode [C]` = col_character(),
    `Main Applicant Flag` = col_character(),
    `Application Reference Number` = col_character(),
    `Property Type Code` = col_integer(),
    `Financial Difficulties / Debt / Unemployment` = col_integer(),
    `Physical Health Reasons` = col_integer(),
    `Mental Health Reasons` = col_integer(),
    `Unmet Need for Support from Housing / Social Work / Health Services` = col_integer(),
    `Lack of Support from Friends / Family` = col_integer(),
    `Difficulties Managing on Own` = col_integer(),
    `Drug / Alcohol Dependency` = col_integer(),
    `Criminal / Anti-Social Behaviour` = col_integer(),
    `Not to do with Applicant Household` = col_integer(),
    Refused = col_integer(),
    `Person in Receipt of Universal Credit` = col_integer()
  )
) %>%
  rename(
    assessment_decision_date = `Assessment Decision Date`,
    case_closed_date = `Case Closed Date`,
    sending_local_authority_code_9 = `Sending Local Authority Code 9`,
    client_unique_identifier = `Client Unique Identifier`,
    upi_number = `UPI Number [C]`,
    client_dob_date = `Client DoB Date [C]`,
    age_at_assessment_decision_date = `Age at Assessment Decision Date`,
    gender_code = `Gender Code`,
    client_postcode = `Client Postcode [C]`,
    main_applicant_flag = `Main Applicant Flag`,
    application_reference_number = `Application Reference Number`,
    property_type_code = `Property Type Code`,
    financial_difficulties_debt_unemployment = `Financial Difficulties / Debt / Unemployment`,
    physical_health_reasons = `Physical Health Reasons`,
    mental_health_reasons = `Mental Health Reasons`,
    unmet_need_for_support_from_housing_social_work_health_services = `Unmet Need for Support from Housing / Social Work / Health Services`,
    lack_of_support_from_friends_family = `Lack of Support from Friends / Family`,
    difficulties_managing_on_own = `Difficulties Managing on Own`,
    drug_alcohol_dependency = `Drug / Alcohol Dependency`,
    criminal_anti_social_behaviour = `Criminal / Anti-Social Behaviour`,
    not_to_do_with_applicant_household = `Not to do with Applicant Household`,
    refused = Refused,
    person_in_receipt_of_universal_credit = `Person in Receipt of Universal Credit`
  )

# Add some variables ------------------------------------------------------
data <- homelessness_extract %>%
  mutate(
    year = year,
    recid = "HL1",
    smrtype = case_when(
      main_applicant_flag == "Y" ~ "HL1-Main",
      main_applicant_flag == "N" ~ "HL1-Other"
    )
  ) %>%
  mutate(across(c(financial_difficulties_debt_unemployment:refused), replace_na, 9L),
    hl1_reason_ftm = paste0(
      if_else(financial_difficulties_debt_unemployment == 1L, "F", ""),
      if_else(physical_health_reasons == 1L, "Ph", ""),
      if_else(mental_health_reasons == 1L, "M", ""),
      if_else(unmet_need_for_support_from_housing_social_work_health_services == 1L, "U", ""),
      if_else(lack_of_support_from_friends_family == 1L, "L", ""),
      if_else(difficulties_managing_on_own == 1L, "O", ""),
      if_else(drug_alcohol_dependency == 1L, "D", ""),
      if_else(criminal_anti_social_behaviour == 1L, "C", ""),
      if_else(not_to_do_with_applicant_household == 1L, "N", ""),
      if_else(refused == 1L, "R", "")
    )
  )

# Filter data -------------------------------------------------------------
# TODO - Move completeness code to SLF branch
# Need a file from SG - goes in SLF_Extracts/Homelessness
# Take a full extract from BOXI then run the below code (or similar)
# annual_comparison %>%
#   left_join(la_code_lookup, by = c(sending_local_authority_name = "CAName")) %>%
#   select(sending_local_authority_code_9 = CA, fin_year, pct_complete_all) %>%
#   # When we don't have completeness (e.g. for the latest year)
#   # Use the previous year's completeness
#   group_by(sending_local_authority_code_9) %>%
#   fill(pct_complete_all) %>%
#   ungroup() %>%
#   readr::write_rds(fs::path("/conf/hscdiip/SLF_Extracts/Homelessness/homelessness_completeness_Mar_2022.rds"))
#
# Then will use the single 'full' boxi extract to pick out each year.
# For now I've just created the file elsewhere to be picked up here!

la_code_lookup <- phsopendata::get_resource("967937c4-8d67-4f39-974f-fd58c4acfda5") %>%
  dplyr::distinct(CA, CAName) %>%
  dplyr::mutate(
    sending_local_authority_name = dplyr::recode(
      CAName,
      "City of Edinburgh" = "Edinburgh",
      "Na h-Eileanan Siar" = "Eilean Siar"
    ) %>%
      stringr::str_replace("\\sand\\s", " \\& ")
  )

completeness_data <- read_rds(get_file_path(
  directory = fs::path(get_slf_dir(), "Homelessness"),
  file_name = glue::glue("homelessness_completeness_{latest_update()}.rds")
)) %>%
  mutate(year = convert_year_to_fyyear(fin_year))

filtered_data <- left_join(data, la_code_lookup, by = c("sending_local_authority_code_9" = "CA")) %>%
  left_join(completeness_data,
    by = c("sending_local_authority_name", "year")
  ) %>%
  # Keep where the completeness is between 90% and 110%
  # Or if it's East Ayrshire (S12000008) as they are submitting something different.
  filter(between(pct_complete_all, 0.90, 1.05) | sending_local_authority_code_9 == "S12000008")



# Rename and select ---------------------------------------------------------
# TODO - Include person_id (from client_id)
final_data <- filtered_data %>%
  select(year,
    recid,
    smrtype,
    chi = upi_number,
    dob = client_dob_date,
    age = age_at_assessment_decision_date,
    gender = gender_code,
    postcode = client_postcode,
    record_keydate1 = assessment_decision_date,
    record_keydate2 = case_closed_date,
    hl1_application_ref = application_reference_number,
    hl1_sending_lca = sending_local_authority_code_9,
    hl1_property_type = property_type_code,
    hl1_reason_ftm
  )

# Changes only required for SPSS ------------------------------------------
final_data <- final_data %>%
  replace_na(list(chi = "")) %>%
  mutate(across(c(record_keydate1, record_keydate2), date_to_numeric)) %>%
  arrange(chi, record_keydate1, record_keydate2) %>%
  mutate(postcode = stringr::str_pad(postcode, width = 8, side = "right"),
         smrtype = stringr::str_pad(smrtype, width = 10, side = "right"),
         hl1_application_ref = stringr::str_pad(hl1_application_ref, width = 15, side = "right"))

# Write data --------------------------------------------------------------
final_data %>%
  readr::write_rds(get_file_path(get_year_dir(year), glue::glue("homelessness_for_source-20{year}"), ext = "rds", check_mode = "write"),
    compress = "gz"
  ) %>%
  haven::write_sav(get_file_path(get_year_dir(year), glue::glue("homelessness_for_source-20{year}"), ext = "zsav", check_mode = "write"),
    compress = TRUE
  )
