#' Process the homelessness extract
#'
#' @description This will read and process the
#' homelessness extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk.
#'
#' @return the final data as a tibble.
#' @export
#' @family Process extracts
#'
#' @importFrom readr col_date col_character col_integer
process_homelessness_extract <- function(year, write_to_disk = TRUE) {
  # Read the data and clean the variable names ------------------------------

  homelessness_extract <- readr::read_csv(extract_path(year = year, type = "Homelessness"),
    col_types = readr::cols(
      "Assessment Decision Date" = col_date(format = "%Y%m%d %T"),
      "Case Closed Date" = col_date(format = "%Y%m%d %T"),
      "Sending Local Authority Code 9" = col_character(),
      "Client Unique Identifier" = col_character(),
      "UPI Number [C]" = col_character(),
      "Client DoB Date [C]" = col_date(format = "%Y%m%d %T"),
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

  # Add some variables ------------------------------------------------------
  data <- homelessness_extract %>%
    dplyr::mutate(
      year = year,
      recid = "HL1",
      smrtype = dplyr::case_when(
        main_applicant_flag == "Y" ~ "HL1-Main",
        main_applicant_flag == "N" ~ "HL1-Other"
      )
    ) %>%
    dplyr::mutate(dplyr::across(c(.data$financial_difficulties_debt_unemployment:.data$refused), tidyr::replace_na, 9L),
      hl1_reason_ftm = paste0(
        dplyr::if_else(.data$financial_difficulties_debt_unemployment == 1L, "F", ""),
        dplyr::if_else(.data$physical_health_reasons == 1L, "Ph", ""),
        dplyr::if_else(.data$mental_health_reasons == 1L, "M", ""),
        dplyr::if_else(.data$unmet_need_for_support_from_housing_social_work_health_services == 1L, "U", ""),
        dplyr::if_else(.data$lack_of_support_from_friends_family == 1L, "L", ""),
        dplyr::if_else(.data$difficulties_managing_on_own == 1L, "O", ""),
        dplyr::if_else(.data$drug_alcohol_dependency == 1L, "D", ""),
        dplyr::if_else(.data$criminal_anti_social_behaviour == 1L, "C", ""),
        dplyr::if_else(.data$not_to_do_with_applicant_household == 1L, "N", ""),
        dplyr::if_else(.data$refused == 1L, "R", "")
      )
    )

  # Filter data -------------------------------------------------------------
  # TODO - Move completeness code to SLF branch
  # Need a file from SG - goes in SLF_Extracts/Homelessness
  # Take a full extract from BOXI then run the below code (or similar)
  # annual_comparison %>%
  #   dplyr::left_join(la_code_lookup, by = c(sending_local_authority_name = "CAName")) %>%
  #  dplyr::select(sending_local_authority_code_9 = CA, fin_year, pct_complete_all) %>%
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
    dplyr::distinct(.data$CA, .data$CAName) %>%
    dplyr::mutate(
      sending_local_authority_name = dplyr::recode(
        .data$CAName,
        "City of Edinburgh" = "Edinburgh",
        "Na h-Eileanan Siar" = "Eilean Siar"
      ) %>%
        stringr::str_replace("\\sand\\s", " \\& ")
    )

  completeness_data <- readr::read_rds(get_file_path(
    directory = fs::path(get_slf_dir(), "Homelessness"),
    file_name = glue::glue("homelessness_completeness_{latest_update()}.rds")
  )) %>%
    dplyr::mutate(year = convert_year_to_fyyear(.data$fin_year))

  filtered_data <- dplyr::left_join(data, la_code_lookup, by = c("sending_local_authority_code_9" = "CA")) %>%
    dplyr::left_join(completeness_data,
      by = c("sending_local_authority_name", "year")
    ) %>%
    # Keep where the completeness is between 90% and 110%
    # Or if it's East Ayrshire (S12000008) as they are submitting something different.
    dplyr::filter(dplyr::between(.data$pct_complete_all, 0.90, 1.05) | .data$sending_local_authority_code_9 == "S12000008")



  # dplyr::rename and select ---------------------------------------------------------
  # TODO - Include person_id (from client_id)
  final_data <- filtered_data %>%
    # Filter out duplicates
    fix_west_dun_duplicates() %>%
    fix_east_ayrshire_duplicates() %>%
    dplyr::select(
      .data$year,
      .data$recid,
      .data$smrtype,
      chi = .data$upi_number,
      dob = .data$client_dob_date,
      age = .data$age_at_assessment_decision_date,
      gender = .data$gender_code,
      postcode = .data$client_postcode,
      record_keydate1 = .data$assessment_decision_date,
      record_keydate2 = .data$case_closed_date,
      hl1_application_ref = .data$application_reference_number,
      hl1_sending_lca = .data$sending_local_authority_code_9,
      hl1_property_type = .data$property_type_code,
      .data$hl1_reason_ftm
    )

  # Changes only required for SPSS ------------------------------------------
  final_data <- final_data %>%
    tidyr::replace_na(list(chi = "")) %>%
    dplyr::mutate(dplyr::across(c(.data$record_keydate1, .data$record_keydate2), date_to_numeric)) %>%
    dplyr::arrange(.data$chi, .data$record_keydate1, .data$record_keydate2) %>%
    dplyr::mutate(
      postcode = stringr::str_pad(.data$postcode, width = 8, side = "right"),
      smrtype = stringr::str_pad(.data$smrtype, width = 10, side = "right"),
      hl1_application_ref = stringr::str_pad(.data$hl1_application_ref, width = 15, side = "right")
    )

  # Write data --------------------------------------------------------------
  if (write_to_disk) {
    final_data %>%
      readr::write_rds(get_file_path(get_year_dir(year), glue::glue("homelessness_for_source-20{year}"), ext = "rds", check_mode = "write"),
        compress = "gz"
      ) %>%
      haven::write_sav(get_file_path(get_year_dir(year), glue::glue("homelessness_for_source-20{year}"), ext = "zsav", check_mode = "write"),
        compress = TRUE
      )
  }

  return(final_data)
}


#' Fix the West Dunbartonshire duplicates
#'
#' @description Takes the homelessness data and filters out
#' the West Dun duplicates where one has an app_number e.g.
#' "ABC123" and another has "00ABC123". It first modifies IDs
#' of this type and then filters where this 'creates' a duplicate.
#'
#' @param data the homelessness data - It must contain the
#' `sending_local_authority_name`, `application_reference_number`,
#' `client_unique_identifier`, `assessment_decision_date` and
#' `case_closed_date`.
#'
#' @return The fixed data
fix_west_dun_duplicates <- function(data) {
  west_dun_fixed <- data %>%
    dplyr::filter(.data$sending_local_authority_name == "West Dunbartonshire") %>%
    # Remove the leading zeros
    dplyr::mutate(dplyr::across(
      c(.data$application_reference_number, .data$client_unique_identifier),
      ~ stringr::str_remove(.x, "^00")
    )) %>%
    # Sort so the latest case closed date is at the top
    dplyr::arrange(dplyr::desc(.data$case_closed_date)) %>%
    # Keep only the first record for app_ref, client_id, decision_date.
    dplyr::distinct(.data$application_reference_number, .data$client_unique_identifier, .data$assessment_decision_date,
      .keep_all = TRUE
    )

  fixed_data <- dplyr::bind_rows(
    data %>%
      dplyr::filter(.data$sending_local_authority_name != "West Dunbartonshire"),
    west_dun_fixed
  )

  return(fixed_data)
}


#' Fix the East Ayrshire duplicates
#'
#' @description Takes the homelessness data and filters out
#' the East Ayrshire duplicates where one has an app_number e.g.
#' "ABC12345" and another has "ABC/12/345". It first modifies IDs
#' of this type and then filters where this 'creates' a duplicate.
#' The IDs with the `/` are more common so we add these rather than
#' remove them.
#'
#' @param data the homelessness data - It must contain the
#' `sending_local_authority_name`, `application_reference_number`,
#' `client_unique_identifier`, `assessment_decision_date` and
#' `case_closed_date`.
#'
#' @return The fixed data
fix_east_ayrshire_duplicates <- function(data) {
  east_ayrshire_fixed <- data %>%
    dplyr::filter(.data$sending_local_authority_name == "East Ayrshire") %>%
    # Remove the leading zeros
    dplyr::mutate(dplyr::across(
      c(.data$application_reference_number, .data$client_unique_identifier),
      ~ stringr::str_replace(.x, "^([A-Z]{2,3})([0-9]{2})(.+?)$", "\\1/\\2/\\3")
    )) %>%
    # Sort so the latest case closed date is at the top
    dplyr::arrange(dplyr::desc(.data$case_closed_date)) %>%
    # Keep only the first record for app_ref, client_id, decision_date.
    dplyr::distinct(.data$application_reference_number, .data$client_unique_identifier, .data$assessment_decision_date,
      .keep_all = TRUE
    )

  fixed_data <- dplyr::bind_rows(
    data %>%
      dplyr::filter(.data$sending_local_authority_name != "East Ayrshire"),
    east_ayrshire_fixed
  )
}
