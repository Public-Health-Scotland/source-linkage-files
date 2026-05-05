#' Process the GP OoH extract
#'
#' @description This will read and process the
#' GP OoH extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param year The year to process, in FY format.
#' @param data_list A list containing the extracts.
#' @param gp_ooh_cup_path path to gp ooh cup data
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_gp_ooh <- function(year,
                                   data_list,
                                   denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                   gp_ooh_cup_path = get_boxi_extract_path(year, "gp_ooh_cup", BYOC_MODE = BYOC_MODE),
                                   write_to_disk = TRUE,
                                   BYOC_MODE = FALSE,
                                   run_id = NA,
                                   run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "gpooh", year = year)

  diagnosis_extract <- process_extract_ooh_diagnosis(data_list[["diagnosis"]], year)
  outcomes_extract <- process_extract_ooh_outcomes(data_list[["outcomes"]], year)
  consultations_extract <- process_extract_ooh_consultations(data_list[["consultations"]], year)


  # Join data ---------------------------------

  matched_data <- consultations_extract %>%
    dplyr::left_join(diagnosis_extract, by = "ooh_case_id") %>%
    dplyr::left_join(outcomes_extract, by = "ooh_case_id")


  # Costs ---------------------------------

  # OOH cost lookup
  ooh_cost_lookup <- read_file(get_gp_ooh_costs_path()) %>%
    dplyr::rename(
      hbtreatcode = "TreatmentNHSBoardCode"
    )

  # --- DUMMY DENODO COST LOOKUP ---
  # on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # ooh_cost_lookup <- dplyr::tbl(
  #   denodo_connect,
  #   dbplyr::in_schema("sdl", "sdl_gp_ooh_costs_placeholder") # TO-DO: Update denodo table name later
  # ) %>%
  #   dplyr::rename(hbtreatcode = "treatment_nhs_board_code") %>% # TO-DO: or TreatmentNHSBoardCode to match Denodo snake_case given
  #   dplyr::collect()
  # --------------------------------

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


  # Final cleaning  ---------------------------------

  ooh_clean <- ooh_costs %>%
    dplyr::mutate(
      # Replace location unknown with NA
      location = dplyr::na_if(.data$location, "UNKNOWN"),
      recid = "OoH",
      smrtype = add_smrtype(.data$recid, consultation_type = .data$consultation_type),
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
      keytime1 = hms::as_hms(.data$record_keydate1),
      keytime2 = hms::as_hms(.data$record_keydate2),
      record_keydate1 = trunc(.data$record_keydate1, "days"),
      record_keydate2 = trunc(.data$record_keydate2, "days")
    ) %>%
    dplyr::mutate(
      record_keydate1 = as.Date(.data$record_keydate1),
      record_keydate2 = as.Date(.data$record_keydate2)
    )

  # Keep the location descriptions as a lookup.
  location_lookup <- ooh_clean %>%
    dplyr::group_by(.data$location) %>%
    dplyr::summarise(
      location_description = dplyr::first(.data$location_description)
    ) %>%
    dplyr::ungroup()

  ## Link CUP Marker -----

  # --- DUMMY DENODO CUP LOOKUP ---
  # c_year_cup <- convert_fyyear_to_year(check_year_format(year))
  #
  # gp_ooh_cup_file <- dplyr::tbl(
  #   denodo_connect,
  #   dbplyr::in_schema("sdl", "sdl_gp_ooh_cup_placeholder") # TO-DO: update denodo table name later
  # ) %>%
  #   dplyr::filter(year == c_year_cup) %>% # TO-DO: if filter required to select cup-marker for financial year
  #   dplyr::select(
  #     record_keydate1 = "consultation_start_date",
  #     keytime1 = "consultation_start_time",
  #     ooh_case_id = "guid",
  #     cup_marker = "cup_marker",
  #     cup_pathway = "cup_pathway_name"
  #   ) %>%
  #   dplyr::collect() %>%
  #   dplyr::distinct(record_keydate1, keytime1, ooh_case_id, .keep_all = TRUE)
  # -------------------------------

  gp_ooh_cup_file <- read_file(
    path = gp_ooh_cup_path,
    col_type = readr::cols(
      "GP OOH Consultation Start Date" = readr::col_date(format = "%Y/%m/%d %T"),
      "GP OOH Consultation Start Time" = readr::col_time(""),
      "GUID" = readr::col_character(),
      "CUP Marker" = readr::col_integer(),
      "CUP Pathway Name" = readr::col_character()
    )
  ) %>%
    dplyr::select(
      record_keydate1 = "GP OOH Consultation Start Date",
      keytime1 = "GP OOH Consultation Start Time",
      ooh_case_id = "GUID",
      cup_marker = "CUP Marker",
      cup_pathway = "CUP Pathway Name"
    ) %>%
    dplyr::distinct(
      .data$record_keydate1,
      .data$keytime1,
      .data$ooh_case_id,
      .keep_all = TRUE
    )

  ooh_clean <- ooh_clean %>%
    dplyr::left_join(gp_ooh_cup_file,
      by = dplyr::join_by(
        "ooh_case_id",
        "record_keydate1",
        "keytime1"
      )
    )

  ooh_clean <- ooh_clean %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )

  ## Save Outfile -------------------------------------

  final_data <- ooh_clean %>%
    dplyr::select(
      "run_id",
      "run_date_time",
      "year",
      "recid",
      "smrtype",
      "record_keydate1",
      "record_keydate2",
      "keytime1",
      "keytime2",
      "anon_chi",
      "gender",
      "dob",
      "gpprac",
      "postcode",
      "hbrescode",
      "hscp",
      "hbtreatcode",
      "location",
      "attendance_status",
      "kis_accessed",
      "refsource",
      tidyselect::starts_with("diag"),
      tidyselect::starts_with("ooh_outcome"),
      "cost_total_net",
      tidyselect::ends_with("_cost"),
      "ooh_case_id",
      "cup_marker",
      "cup_pathway"
    )

  if (write_to_disk) {
    final_data %>%
      write_file(
        get_source_extract_path(year, "gp_ooh", check_mode = "write", BYOC_MODE = BYOC_MODE),
        BYOC_MODE = BYOC_MODE,
        group_id = 3356
      ) # sourcedev owner
  }

  log_slf_event(stage = "process", status = "complete", type = "gpooh", year = year)

  return(final_data)
}
