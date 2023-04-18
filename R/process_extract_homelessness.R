#' Process the Homelessness Extract
#'
#' @description This will read and process the
#' homelessness extract, it will return the final data
#' and optionally write it out as rds.
#'
#' @param data The extract to process from [read_extract_homelessness()].
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param update The update to use (default is [latest_update()]).
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
    sg_pub_path = get_sg_homelessness_pub_path()) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Add some variables ------------------------------------------------------

  # If data is available in the FY then run processing.
  # If no data has passed through, return NULL.
  if (is.null(data)) {
    return(NULL)
  }
  data <- data %>%
    dplyr::mutate(
      year = as.character(year),
      recid = "HL1",
      smrtype = add_smr_type(
        recid = .data$recid,
        main_applicant_flag = .data$main_applicant_flag
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(
        c("financial_difficulties_debt_unemployment":"refused"),
        ~ tidyr::replace_na(.x, 9L)
      ),
      hl1_reason_ftm = paste0(
        dplyr::if_else(
          .data$financial_difficulties_debt_unemployment,
          "F",
          ""
        ),
        dplyr::if_else(
          .data$physical_health_reasons,
          "Ph",
          ""
        ),
        dplyr::if_else(
          .data$mental_health_reasons,
          "M",
          ""
        ),
        dplyr::if_else(
          .data$unmet_need_for_support_from_housing_social_work_health_services,
          "U",
          ""
        ),
        dplyr::if_else(
          .data$lack_of_support_from_friends_family,
          "L",
          ""
        ),
        dplyr::if_else(
          .data$difficulties_managing_on_own,
          "O",
          ""
        ),
        dplyr::if_else(
          .data$drug_alcohol_dependency,
          "D",
          ""
        ),
        dplyr::if_else(
          .data$criminal_anti_social_behaviour,
          "C",
          ""
        ),
        dplyr::if_else(
          .data$not_to_do_with_applicant_household,
          "N",
          ""
        ),
        dplyr::if_else(
          .data$refused,
          "R",
          ""
        )
      )
    ) %>%
    dplyr::left_join(
      la_code_lookup(),
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

  if (!is.null(completeness_data)) {
    filtered_data <- data %>%
      dplyr::left_join(completeness_data,
        by = c("year", "sending_local_authority_name")
      ) %>%
      dplyr::filter(
        dplyr::between(.data[["pct_complete_all"]], 0.90, 1.05) |
          .data[["sending_local_authority_name"]] == "East Ayrshire"
      )
  } else {
    filtered_data <- data
  }

  # TODO - Include person_id (from client_id)
  final_data <- filtered_data %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
      chi = "upi_number",
      dob = "client_dob_date",
      age = "age_at_assessment_decision_date",
      gender = "gender_code",
      postcode = "client_postcode",
      record_keydate1 = "assessment_decision_date",
      record_keydate2 = "case_closed_date",
      hl1_application_ref = "application_reference_number",
      hl1_sending_lca = "sending_local_authority_code_9",
      hl1_property_type = "property_type_code",
      "hl1_reason_ftm"
    )

  if (write_to_disk) {
    final_data %>%
      write_rds(get_file_path(
        get_year_dir(year),
        stringr::str_glue("homelessness_for_source-20{year}"),
        ext = "rds",
        check_mode = "write"
      ))
  }

  return(final_data)
}
