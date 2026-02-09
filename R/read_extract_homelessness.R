#' Read Homelessness extract
#'
#' @inherit read_extract_acute
#'
#' @export
read_extract_homelessness <- function(
  year,
  file_path = get_boxi_extract_path(year = year, type = "homelessness"),
  BYOC_MODE
) {
  log_slf_event(stage = "read", status = "start", type = "homelessness", year = year)

  year <- check_year_format(year, format = "alternate")

  # Specify years available for running
  if (file_path == get_dummy_boxi_extract_path(BYOC_MODE = BYOC_MODE)) {
    return(tibble::tibble())
  } # todo: waiting to be finalised

  extract_homelessness <- as_tibble(dbGetQuery(
    denodo_connect,
    stringr::str_glue(
      "select * from sdl.sdl_homelessness_source
        where financial_year_of_assessment <= {year}
        and  (financial_year_of_case_closed is null
              or financial_year_of_case_closed >= {year})"
    )
  )) %>%
    dplyr::select(
      # financial_year_of_assessment,
      # financial_year_of_case_closed,
      assessment_decision_date = "assessment_decision_date",
      case_closed_date = "case_closed_date",
      sending_local_authority_code_9 = "sending_local_authority_code_9",
      client_unique_identifier = "client_unique_identifier",
      chi = "client_chi",
      client_dob_date = "client_dob",
      age_at_assessment_decision_date = "age_at_assessment_decision_date",
      gender_code = "client_sex",
      client_postcode = "client_postcode",
      main_applicant_flag = "main_applicant_flag",
      application_reference_number = "application_reference_number",
      property_type_code = "property_type_code",
      financial_difficulties_debt_unemployment = "financial_difficulties",
      physical_health_reasons = "physical_health_reasons",
      mental_health_reasons = "mental_health_reasons",
      unmet_need_for_support_from_housing_social_work_health_services = "unmet_need_for_suppport_from_housing",
      lack_of_support_from_friends_family = "lack_of_support_from_friends",
      difficulties_managing_on_own = "difficulties_managing_on_own",
      drug_alcohol_dependency = "drug_alcohol_dependency",
      criminal_anti_social_behaviour = "criminal_anti_social_behaviour",
      not_to_do_with_applicant_household = "not_to_do_with_applicant_household",
      refused = "refused",
      person_in_receipt_of_universal_credit = "person_in_receipt_of_universal_credit"
    ) %>%
    slfhelper::get_anon_chi("chi")

  log_slf_event(stage = "read", status = "complete", type = "homelessness", year = year)

  return(extract_homelessness)
}
