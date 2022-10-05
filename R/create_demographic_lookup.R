data <- haven::read_sav("/conf/sourcedev/Source_Linkage_File_Updates/1920/temp-source-episode-file-6-1920.zsav",
  n_max = 250000
)

return_data <- data %>%
  # Remove missing chi
  dplyr::filter(!is_missing(chi)) %>%
  # Add the various cohorts
  assign_demographic_cohort() %>%
  assign_eol_cohort() %>%
  assign_substance_cohort() %>%
  # Aggregate to cij level, specifically so that the drug and alcohol misuse
  # variables can be dealt with properly
  dtplyr::lazy_dt() %>%
  dplyr::group_by(.data$chi, .data$cij_marker) %>%
  dplyr::summarise(
    across(c(dplyr::contains("cohort"), f11, t402_t404, f13, t424), any)
  ) %>%
  dplyr::ungroup() %>%
  tibble::as_tibble() %>%
  # Assign drug and alcohol misuse
  dplyr::mutate(substance_cohort = dplyr::if_else(
    (.data$f11 & .data$t402_t404) | (.data$f13 & .data$t424), T, .data$substance_cohort
  )) %>%
  # Aggregate to CHI level
  dtplyr::lazy_dt() %>%
  dplyr::group_by(.data$chi) %>%
  dplyr::summarise(across(c(dplyr::contains("cohort")), any)) %>%
  dplyr::ungroup() %>%
  tibble::as_tibble() %>%
  # Rename variables
  dplyr::rename_with(~ stringr::str_sub(.x, end = -8), ends_with("_cohort")) %>%
  # Assign demographic_cohort based on hierarchy of each cohort
  dplyr::mutate(demographic_cohort = dplyr::case_when(
    end_of_life ~ "End of Life",
    frail ~ "Frailty",
    high_cc ~ "High Complex Conditions",
    maternity ~ "Maternity and Healthy Newborns",
    mh ~ "Mental Health",
    substance ~ "Substance Misuse",
    medium_cc ~ "Medium Complex Conditions",
    low_cc ~ "Low Complex Conditions",
    child_major ~ "Child Major Conditions",
    adult_major ~ "Adult Major Conditions",
    comm_living ~ "Assisted Living in the Community",
    TRUE ~ "Healthy and Low User"
  ))

demo_real <- haven::read_sav(get_demog_cohorts_path("1920", ext = "zsav"))

test <- dplyr::left_join(
  return_data %>% dplyr::select(chi, demographic_cohort),
  demo_real %>% dplyr::select(chi, Demographic_Cohort),
  by = "chi"
) %>%
  dplyr::mutate(correct = demographic_cohort == Demographic_Cohort) %>%
  dplyr::filter(correct == FALSE)

incorrect_chis <- test$chi

incorrect_all <- return_data %>% dplyr::filter(chi %in% incorrect_chis)
