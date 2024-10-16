#' Process the Homelessness Extract
#'
#' @description This will read and process the
#' homelessness extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process from [read_extract_homelessness()].
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param update The update to use (default is [latest_update()]).
#' @param la_code_lookup get local authority using opendata.
#' @param sg_pub_path The path to the SG pub figures (default is
#' [get_sg_homelessness_pub_path()]).
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_homelessness <- function(
    data,
    year,
    write_to_disk = TRUE,
    update = latest_update(),
    la_code_lookup = get_la_code_opendata_lookup(),
    sg_pub_path = get_sg_homelessness_pub_path()) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # If data is available in the FY then run processing.
  if (identical(data, tibble::tibble())) {
    return(data)
  }

  data <- data %>%
    dplyr::mutate(
      year = as.character(year),
      recid = "HL1",
      smrtype = add_smrtype(
        recid = .data$recid,
        main_applicant_flag = .data$main_applicant_flag
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(
        "financial_difficulties_debt_unemployment":"refused",
        ~ tidyr::replace_na(.x, 9L)
      ),
      hl1_reason_ftm = paste0(
        dplyr::if_else(
          .data$financial_difficulties_debt_unemployment == 1L,
          "F",
          ""
        ),
        dplyr::if_else(
          .data$physical_health_reasons == 1L,
          "Ph",
          ""
        ),
        dplyr::if_else(
          .data$mental_health_reasons == 1L,
          "M",
          ""
        ),
        dplyr::if_else(
          .data$unmet_need_for_support_from_housing_social_work_health_services == 1L,
          "U",
          ""
        ),
        dplyr::if_else(
          .data$lack_of_support_from_friends_family == 1L,
          "L",
          ""
        ),
        dplyr::if_else(
          .data$difficulties_managing_on_own == 1L,
          "O",
          ""
        ),
        dplyr::if_else(
          .data$drug_alcohol_dependency == 1L,
          "D",
          ""
        ),
        dplyr::if_else(
          .data$criminal_anti_social_behaviour == 1L,
          "C",
          ""
        ),
        dplyr::if_else(
          .data$not_to_do_with_applicant_household == 1L,
          "N",
          ""
        ),
        dplyr::if_else(
          .data$refused == 1L,
          "R",
          ""
        )
      )
    ) %>%
    dplyr::mutate(property_type_code = as.character(.data$property_type_code)) %>%
    dplyr::mutate(
      property_type_code = dplyr::case_when(
        .data$property_type_code == "1" ~ "1 - Own Property - LA Tenancy",
        .data$property_type_code == "2" ~ "2 - Own Property - RSL Tenancy",
        .data$property_type_code == "3" ~ "3 - Own Property - private rented tenancy",
        .data$property_type_code == "4" ~ "4 - Own Property - tenancy secured through employment/tied house",
        .data$property_type_code == "5" ~ "5 - Own Property - owning/buying",
        .data$property_type_code == "6" ~ "6 - Parental / family home / relatives",
        .data$property_type_code == "7" ~ " 7 - Friends / partners",
        .data$property_type_code == "8" ~ "8 - Armed Services Accommodation",
        .data$property_type_code == "9" ~ "9 - Prison",
        .data$property_type_code == "10" ~ "10 - Hospital",
        .data$property_type_code == "11" ~ "11 - Children's residential accommodation (looked after by the local authority)",
        .data$property_type_code == "12" ~ "12 - Supported accommodation",
        .data$property_type_code == "13" ~ "13 - Hostel (unsupported)",
        .data$property_type_code == "14" ~ "14 - Bed & Breakfast",
        .data$property_type_code == "15" ~ "15 - Caravan / mobile home",
        .data$property_type_code == "16" ~ "16 - Long-term roofless",
        .data$property_type_code == "17" ~ "17 - Long-term sofa surfing",
        .data$property_type_code == "18" ~ "18 - Other",
        .data$property_type_code == "19" ~ "19 - Not known / refused",
        .data$property_type_code == "20" ~ "20 - Own property - Shared ownership/Shared equity/ LCHO",
        .data$property_type_code == "21" ~ "21 - Lodger",
        .data$property_type_code == "22" ~ "22 - Shared Property - Private Rented Sector",
        .data$property_type_code == "23" ~ "23 - Shared Property - Local Authority",
        .data$property_type_code == "24" ~ "24 - Shared Property - RSL",
        TRUE ~ .data$property_type_code
      )
    ) %>%
    dplyr::left_join(
      la_code_lookup,
      by = dplyr::join_by("sending_local_authority_code_9" == "CA")
    ) %>%
    # Filter out duplicates
    fix_west_dun_duplicates() %>%
    fix_east_ayrshire_duplicates()

  completeness_data <- produce_homelessness_completeness(
    homelessness_data = data,
    update = update,
    sg_pub_path = sg_pub_path
  )

  hl1_data <- data %>%
    dplyr::left_join(
      completeness_data %>%
        dplyr::select(.data$sending_local_authority_name, .data$pct_complete_all),
      by = dplyr::join_by("sending_local_authority_name")
    ) %>%
    dplyr::rename(hl1_completeness = "pct_complete_all") %>%
    dplyr::mutate(hl1_completeness = round(.data$hl1_completeness, 1))

  final_data <- hl1_data %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
      "chi",
      dob = "client_dob_date",
      age = "age_at_assessment_decision_date",
      gender = "gender_code",
      postcode = "client_postcode",
      record_keydate1 = "assessment_decision_date",
      record_keydate2 = "case_closed_date",
      hl1_application_ref = "application_reference_number",
      hl1_sending_lca = "sending_local_authority_code_9",
      hl1_property_type = "property_type_code",
      "hl1_reason_ftm",
      "hl1_completeness"
    ) %>%
    slfhelper::get_anon_chi()

  if (write_to_disk) {
    write_file(
      final_data,
      get_source_extract_path(
        year = year,
        type = "homelessness",
        check_mode = "write"
      )
    )
  }

  return(final_data)
}
