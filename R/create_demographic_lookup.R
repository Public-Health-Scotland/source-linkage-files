#' Create the demographic lookup file
#'
#' @param data A data frame with the required variables
#'
#' @export
#'
#' @seealso \itemize{\item[assign_demographic_cohort()]
#'                   \item[assign_eol_cohort()]
#'                   \item[assign_substance_cohort()]
#'                   \item[get_cohorts_paths()]}
#'
#' @family Demographic and Service Use Cohort functions
create_demographic_lookup <- function(data, year, write_to_disk = TRUE) {
  demo_lookup <- data %>%
    # Remove missing chi
    dplyr::filter(!is_missing(chi)) %>%
    # Add the various cohorts
    assign_demographic_cohort() %>%
    assign_eol_cohort() %>%
    assign_substance_cohort() %>%
    # Aggregate to cij level, specifically so that the drug and alcohol misuse
    # variables can be dealt with properly
    # dtplyr::lazy_dt() %>%
    dplyr::group_by(.data$chi, .data$cij_marker) %>%
    dplyr::summarise(
      dplyr::across(c(dplyr::contains("cohort"), f11, t402_t404, f13, t424), any)
    ) %>%
    dplyr::ungroup() %>%
    # tibble::as_tibble() %>%
    # Assign drug and alcohol misuse
    dplyr::mutate(substance_cohort = dplyr::if_else(
      (.data$f11 & .data$t402_t404) | (.data$f13 & .data$t424), TRUE, .data$substance_cohort
    )) %>%
    # Aggregate to CHI level
    # dtplyr::lazy_dt() %>%
    dplyr::group_by(.data$chi) %>%
    dplyr::summarise(across(c(dplyr::contains("cohort")), any)) %>%
    dplyr::ungroup() %>%
    # tibble::as_tibble() %>%
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
    )) %>%
    # Reorder variables
    dplyr::relocate(demographic_cohort, .after = chi)

  # Write to disk
  if (write_to_disk == TRUE) {
    write_rds(demo_lookup,
      path = glue::glue("{get_slf_dir()}/Cohorts/Demographic_Cohorts_{year}.rds")
    )
  } else {
    return(demo_lookup)
  }
}
