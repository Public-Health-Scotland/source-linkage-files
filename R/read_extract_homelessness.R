#' Read homelessness extract
#'
#' @param year Year of BOXI extract
#'
#' @return csv data file for homelessness
#' @export
#'
read_extract_homelessness <- function(year){

extract_homelessness_path <- get_boxi_extract_path(year = year, type = "Homelessness")

extract_homelessness <- readr::read_csv(homelessness_extract_path,
  col_types = cols(
    "Assessment Decision Date" = col_date(format = "%Y/%m/%d %T"),
    "Case Closed Date" = col_date(format = "%Y/%m/%d %T"),
    "Sending Local Authority Code 9" = col_character(),
    "Client Unique Identifier" = col_character(),
    "UPI Number [C]" = col_character(),
    "Client DoB Date [C]" = col_date(format = "%Y/%m/%d %T"),
    "Age at Assessment Decision Date" = col_integer(),
    "Gender Code" = col_integer(),
    "Client Postcode [C]" = col_character(),
    "Main Applicant Flag" = col_character(),
    "Application Reference Number" = col_character(),
    "Property Type Code" = col_integer(),
    "Financial Difficulties / Debt / Unemployment" = col_integer(),
    "Physical Health Reasons" = col_integer(),
    "Mental Health Reasons" = col_integer(),
    "Unmet Need for Support from Housing / Social Work / Health Services" = col_integer(),
    "Lack of Support from Friends / Family" = col_integer(),
    "Difficulties Managing on Own" = col_integer(),
    "Drug / Alcohol Dependency" = col_integer(),
    "Criminal / Anti-Social Behaviour" = col_integer(),
    "Not to do with Applicant Household" = col_integer(),
    "Refused" = col_integer(),
    "Person in Receipt of Universal Credit" = col_integer()
  )
) %>%
  dplyr::rename(
    assessment_decision_date = "Assessment Decision Date",
    case_closed_date = "Case Closed Date",
    sending_local_authority_code_9 = "Sending Local Authority Code 9",
    client_unique_identifier = "Client Unique Identifier",
    upi_number = "UPI Number [C]",
    client_dob_date = "Client DoB Date [C]",
    age_at_assessment_decision_date = "Age at Assessment Decision Date",
    gender_code = "Gender Code",
    client_postcode = "Client Postcode [C]",
    main_applicant_flag = "Main Applicant Flag",
    application_reference_number = "Application Reference Number",
    property_type_code = "Property Type Code",
    financial_difficulties_debt_unemployment = "Financial Difficulties / Debt / Unemployment",
    physical_health_reasons = "Physical Health Reasons",
    mental_health_reasons = "Mental Health Reasons",
    unmet_need_for_support_from_housing_social_work_health_services = "Unmet Need for Support from Housing / Social Work / Health Services",
    lack_of_support_from_friends_family = "Lack of Support from Friends / Family",
    difficulties_managing_on_own = "Difficulties Managing on Own",
    drug_alcohol_dependency = "Drug / Alcohol Dependency",
    criminal_anti_social_behaviour = "Criminal / Anti-Social Behaviour",
    not_to_do_with_applicant_household = "Not to do with Applicant Household",
    refused = "Refused",
    person_in_receipt_of_universal_credit = "Person in Receipt of Universal Credit"
  )

return(extract_homelessness)

}
