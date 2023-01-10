#' Process the GP OoH extract
#'
#' @description This will read and process the
#' GP OoH extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_gp_ooh <- function(year, data_list, write_to_disk = TRUE) {

    diagnosis_extract <- process_extract_ooh_diagnosis(ooh_extracts[["diagnosis"]], year)
    outcomes_extract <- process_extract_ooh_outcomes(ooh_extracts[["outcomes"]], year)
    consultations_extract <- process_extract_ooh_consultations(ooh_extracts[["consultations"]], year)


    # Join data ---------------------------------

    matched_data <- consultations_extract %>%
      dplyr::left_join(diagnosis_extract, by = "ooh_case_id") %>%
      dplyr::left_join(outcomes_extract, by = "ooh_case_id")

    rm(consultations_clean, diagnosis_clean, outcomes_clean)

    # Costs ---------------------------------

    # OOH cost lookup
    ooh_cost_lookup <- readr::read_rds(get_gp_ooh_costs_path()) %>%
      dplyr::rename(
        hbtreatcode = "TreatmentNHSBoardCode"
      )

    ooh_costs <- matched_data %>%
      dplyr::mutate(
        hbtreatcode = dplyr::case_when(
          # Recode Fife and Tayside so they match the cost lookup.
          hbtreatcode == "S08000018" ~ "S08000029",
          hbtreatcode == "S08000027" ~ "S08000030",
          # Recode Greater Glasgow & Clyde and Lanarkshire so they
          # match the costs lookup (2018 -> 2019 HB codes).
          hbtreatcode == "S08000021" ~ "S08000031",
          hbtreatcode == "S08000023" ~ "S08000032",
          TRUE ~ hbtreatcode
        ),
        year = year
      ) %>%
      # Match to cost lookup
      dplyr::left_join(ooh_cost_lookup, by = c("hbtreatcode", "year")) %>%
      dplyr::rename(
        cost_total_net = "cost_per_consultation"
      ) %>%
      create_day_episode_costs(.data$record_keydate1, .data$cost_total_net)

    rm(matched_data, ooh_cost_lookup)

    # Final cleaning  ---------------------------------

    ooh_clean <- ooh_costs %>%
      dplyr::mutate(
        # Replace location unknown with NA
        location = dplyr::na_if(.data$location, "UNKNOWN"),
        recid = "OoH",
        smrtype = add_smr_type(.data$recid, consultation_type = .data$consultation_type),
        kis_accessed = factor(
          dplyr::case_when(
            kis_accessed == "Y" ~ 1L,
            kis_accessed == "N" ~ 0L,
            TRUE ~ 9L
          ),
          levels = c(0L, 1L, 9L),
          labels = c("Y", "N", "Unknown")
        ),
        gpprac = convert_eng_gpprac_to_dummy(.data$gpprac),
        # Split the time from the date
        key_time1 = hms::as_hms(.data$record_keydate1),
        key_time2 = hms::as_hms(.data$record_keydate2),
        record_keydate1 = trunc(.data$record_keydate1, "days"),
        record_keydate2 = trunc(.data$record_keydate2, "days")
      ) %>%
      dplyr::mutate(
        record_keydate1 = as.Date(.data$record_keydate1),
        record_keydate2 = as.Date(.data$record_keydate2)
      )

    # Keep the location descriptions as a lookup.
    # TODO write the GP OoH lookup out using some functions
    location_lookup <- ooh_clean %>%
      dplyr::group_by(.data$location) %>%
      dplyr::summarise(
        location_description = dplyr::first(location_description)
      ) %>%
      dplyr::ungroup()


    ## Save Outfile -------------------------------------

    final_data <- ooh_clean %>%
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
        "gpprac",
        "postcode",
        "hbrescode",
        "datazone",
        "hscp",
        "hbtreatcode",
        "location",
        "attendance_status",
        "kis_accessed",
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
        "ooh_case_id"
      )

    rm(location_lookup, ooh_clean, ooh_costs)

    if (write_to_disk) {
      final_data %>%
        write_rds(get_source_extract_path(year, "GPOoH", check_mode = "write"))
    }

}
