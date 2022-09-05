#' Process the homelessness extract
#'
#' @description This will read and process the
#' homelessness extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param year The year to process, in FY format.
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_homelessness <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Add some variables ------------------------------------------------------
  data <- data %>%
    dplyr::mutate(
      year = as.character(year),
      recid = "HL1",
      smrtype = dplyr::case_when(
        main_applicant_flag == "Y" ~ "HL1-Main",
        main_applicant_flag == "N" ~ "HL1-Other"
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(
        c(.data$financial_difficulties_debt_unemployment:.data$refused),
        tidyr::replace_na, 9L
      ),
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

  # TODO make the la_code_lookup a testable function
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

  completeness_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Homelessness"),
    file_name = glue::glue("homelessness_completeness_{latest_update()}.rds")
  )

  completeness_data <- readr::read_rds(completeness_file_path) %>%
    dplyr::mutate(year = convert_year_to_fyyear(.data$fin_year)) %>%
    dplyr::left_join(la_code_lookup,
                     by = c("sending_local_authority_code_9" = "CA")
    ) %>%
    dplyr::select(-.data$CAName, -.data$sending_local_authority_code_9)

  filtered_data <- data %>%
    dplyr::left_join(la_code_lookup,
                     by = c("sending_local_authority_code_9" = "CA")
    ) %>%
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
    dplyr::mutate(dplyr::across(c(.data$record_keydate1, .data$record_keydate2), convert_date_to_numeric)) %>%
    dplyr::arrange(.data$chi, .data$record_keydate1, .data$record_keydate2) %>%
    dplyr::mutate(
      postcode = stringr::str_pad(.data$postcode, width = 8, side = "right"),
      smrtype = stringr::str_pad(.data$smrtype, width = 10, side = "right"),
      hl1_application_ref = stringr::str_pad(.data$hl1_application_ref, width = 15, side = "right")
    )

  # Write data --------------------------------------------------------------
  if (write_to_disk) {
    final_data %>%
      write_rds(get_file_path(
        get_year_dir(year),
        glue::glue("homelessness_for_source-20{year}test"),
        ext = "rds",
        check_mode = "write"
      )) %>%
      write_sav(get_file_path(
        get_year_dir(year),
        glue::glue("homelessness_for_source-20{year}test"),
        ext = "zsav",
        check_mode = "write"
      ))
  }

  return(final_data)
}
