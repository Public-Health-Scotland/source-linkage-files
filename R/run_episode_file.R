run_episode_file <- function() {
  # Bring all the datasets together from Jen's process functions
  ep_file <- dplyr::bind_rows(processed_data_list)

  # From C01 ----
  # Check chi is valid using phsmethods function
  # If the CHI is invalid for whatever reason, set the CHI to blank string
  temp_file <- test %>%
    dplyr::mutate(chi = dplyr::if_else(phsmethods::chi_check(.data$chi) != "Valid CHI", "", .data$chi)) %>%
    # In original C01, set dates to date format - this doesn't need to be done
    # Set SMRtype, doesn't need to be done
    # Recode any cij_admtype "Un" to "99"
    # There are lots of blanks - do these need to be recoded or ignored?
    # Change some values of cij_pattype_code based on cij_admtype
    dplyr::mutate(
      cij_pattype_code = dplyr::case_when(
        .data$chi != "" &
          .data$recid %in% c("01B", "04B", "GLS", "02B") &
          .data$cij_admtype %in% c("41", "42") ~ 2,
        .data$chi != "" &
          .data$recid %in% c("01B", "04B", "GLS", "02B") &
          .data$cij_admtype %in% c("48", "49", "99") ~ 9,
        .data$cij_admtype == "18" ~ 0,
        TRUE ~ .data$cij_pattype_code
      ),
      # Recode cij_pattype based on above
      cij_pattype = dplyr::case_when(
        .data$cij_pattype_code == 0 ~ "Non-Elective",
        .data$cij_pattype_code == 1 ~ "Elective",
        .data$cij_pattype_code == 2 ~ "Maternity",
        .data$cij_pattype_code == 9 ~ "Other"
      )
    )

  # Work on cij_only records

  cij_only <- ep_file %>%
    # Get cij-only records
    dplyr::filter(.data$recid %in% c("01B", "04B", "GLS", "02B")) %>%
    dplyr::group_by(.data$chi) %>%
    # We want any NA cij_markers to be filled in, if they are the first in the group and
    # are NA. This is why we use this arrange() before the mutate()
    dplyr::arrange(desc(is.na(cij_marker)), .by_group = TRUE) %>%
    dplyr::mutate(cij_marker = dplyr::if_else(
      .data$chi != "" & is.na(.data$cij_marker) & dplyr::row_number() == 1, 1, .data$cij_marker
    )) %>%
    dplyr::ungroup() %>%
    # Tidy up cij_ipdc
    dplyr::mutate(cij_ipdc = dplyr::case_when(
      .data$chi != "" & is_missing(.data$cij_ipdc) & .data$ipdc == "I" ~ "I",
      .data$chi != "" & is_missing(.data$cij_ipdc) & .data$recid == "01B" & .data$ipdc == "D" ~ "D",
      TRUE ~ .data$cij_ipdc
    )) %>%
    # Ensure every record with a chi has a valid cij marker
    dplyr::group_by(.data$chi, .data$cij_marker) %>%
    dplyr::mutate(
      cij_ipdc = max(.data$cij_ipdc),
      cij_admtype = dplyr::first(.data$cij_admtype),
      cij_pattype_code = dplyr::first(.data$cij_pattype_code),
      cij_pattype = dplyr::first(.data$cij_pattype),
      cij_adm_spec = dplyr::first(.data$cij_adm_spec),
      cij_dis_spec = dplyr::last(.data$cij_dis_spec)
    ) %>%
    dplyr::ungroup()

  # Combine the cij-only records with the non-cij records
  temp_file_1 <- dplyr::bind_rows(
    cij_only,
    ep_file %>% dplyr::filter(!(.data$recid %in% c("01B", "04B", "GLS", "02B")))
  ) %>%
    # Create cost including DNAs and modify cost not including DNAs using cattend
    dplyr::mutate(
      cost_total_net_inc_dnas = cost_total_net,
      # In the Cost_Total_Net column set the cost for
      # those with attendance status 5 or 8 (CNWs and DNAs)
      cost_total_net = dplyr::if_else(attendance_status %in% c(5, 8), 0, cost_total_net)
    ) %>%
    # Add the flag for Potentially Preventable Admissions
    add_ppa_flag()

  # From C02 - Link Delayed Discharge Episodes ----
  # Create Temp File 2

  # From C03 - Link Homelessness ----
  # Create Temp File 3

  # From C04 - Add NSU cohort ----

  temp_file_4 <- add_nsu_cohort(temp_file_3, year)

  # From C05 - Match on LTCs ----
  # Create Temp File 5

  # From C06 - Deaths Fixes ----
  # Create Temp File 6

  # From C07 - Calculate and write out pathways cohorts ----
  create_demographic_lookup(temp_file_6, year, write_to_disk = TRUE)
  create_service_use_lookup(temp_file_6, year, write_to_disk = TRUE)

  # From C08 - Match on CHI from Service Use cohort, Demographic cohort, SPARRA and HHG ----
  # Create Temp File 7

  # From C09 - Match on postcode and gpprac variables ----
  # Create Temp File 8

  # From C10 - Final tidy-up (mostly variable labels) ----
  # Create Episode File

  # C10X - Create Tests? Possibly for a different function ----
  # Output tests
}
