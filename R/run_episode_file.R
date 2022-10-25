run_episode_file <- function() {
  # Bring all the datasets together from Jen's process functions
  ep_file <- dplyr::bind_rows(processed_data_list)

  # Check chi is valid using phsmethods function
  # If the CHI is invalid for whatever reason, set the CHI to blank string
  ep_file <- test %>%
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
        .data$cij_pattype_code == 9 ~ "Other",
        TRUE ~ .data$cij_pattype
      )
    )

  # Work on cij_only records

  cij_only <- ep_file %>%
    # Get cij-only records
    dplyr::filter(.data$recid %in% c("01B", "04B", "GLS", "02B")) %>%
    # Set cij_marker to 1 if there is no cij_marker already and it's the first record with
    # that chi
    dplyr::group_by(.data$chi) %>%
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
    # Ensure every
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
}
