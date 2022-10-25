#' Create the demographic lookup file
#'
#' @param data A data frame with the required variables
#' @param year The year in standard SLF format
#' @param write_to_disk Defaults to TRUE
#'
#' @export
#'
#' @seealso \itemize{\item[assign_demographic_cohort()]
#'                   \item[assign_eol_cohort()]
#'                   \item[assign_substance_cohort()]}
#'
#' @family Demographic and Service Use Cohort functions
create_demographic_lookup <- function(data, year, write_to_disk = TRUE) {
  check_variables_exist(
    data,
    c(
      "chi", "cij_marker", "recid", "diag1", "diag2", "diag3", "diag4", "diag5", "diag6", "age", "sigfac", "spec",
      "dementia", "hefailure", "refailure", "liver", "cancer", "cvd", "copd", "chd", "parkinsons", "ms",
      "epilepsy", "asthma", "arth", "diabetes", "atrialfib", "cost_total_net",
      "deathdiag1", "deathdiag2", "deathdiag3", "deathdiag4", "deathdiag5",
      "deathdiag6", "deathdiag7", "deathdiag8", "deathdiag9", "deathdiag10",
      "deathdiag11"
    )
  )

  demo_lookup <- data %>%
    # Remove missing chi
    dplyr::filter(!is_missing(.data$chi)) %>%
    # Add the various cohorts
    assign_demographic_cohort() %>%
    assign_eol_cohort() %>%
    assign_substance_cohort() %>%
    # Aggregate to cij level, specifically so that the drug and alcohol misuse
    # variables can be dealt with properly
    dplyr::group_by(.data$chi, .data$cij_marker) %>%
    dplyr::summarise(
      dplyr::across(c(
        dplyr::contains("cohort"),
        .data$f11, .data$t402_t404, .data$f13, .data$t424
      ), any)
    ) %>%
    dplyr::ungroup() %>%
    # Assign drug and alcohol misuse
    dplyr::mutate(substance_cohort = dplyr::if_else(
      (.data$f11 & .data$t402_t404) | (.data$f13 & .data$t424), TRUE, .data$substance_cohort
    )) %>%
    # Aggregate to CHI level
    dplyr::group_by(.data$chi) %>%
    dplyr::summarise(dplyr::across(c(dplyr::contains("cohort")), any)) %>%
    dplyr::ungroup() %>%
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
    dplyr::relocate(.data$demographic_cohort, .after = chi)

  # Write to disk
  if (write_to_disk == TRUE) {
    write_rds(demo_lookup,
      path = glue::glue("{get_slf_dir()}/Cohorts/Demographic_Cohorts_{year}.rds")
    )
  }

  return(demo_lookup)
}

#' Assign the demographic cohort variables
#'
#' @param data A data frame with the required variables for assignment
#'
#' @return A data frame with ten additional variables relating to the different cohorts
#'
#' @family Demographic and Service Use Cohort functions
assign_demographic_cohort <- function(data) {
  check_variables_exist(data,
    variables =
      c(
        "recid", "diag1", "diag2", "diag3", "diag4", "diag5", "diag6", "age", "sigfac", "spec",
        "dementia", "hefailure", "refailure", "liver", "cancer", "cvd", "copd", "chd", "parkinsons", "ms",
        "epilepsy", "asthma", "arth", "diabetes", "atrialfib", "cost_total_net"
      )
  )

  return_data <- data %>%
    # Mental Health classification
    # FOR FUTURE: when variable MentalHealthProblemsClientGroup exists and is "Y", mh_cohort = TRUE
    dplyr::mutate(
      mh =
        .data$recid == "04B" |

          (.data$recid %in% c("01B", "GLS", "50B", "02B", "04B", "AE2") &
            (rowSums(dplyr::across(
              c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
              ~ stringr::str_sub(.x, 1, 2) %in%
                c("F2", "F3")
            )) > 0 |
              rowSums(dplyr::across(
                c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
                ~ stringr::str_sub(.x, 1, 4) %in%
                  c("F067", "F070", "F072", "F078", "F079")
              )) > 0)),
      # Frailty classification
      # FOR FUTURE: when variable ElderlyFrailClientGroup exists and is "Y", frail_cohort = TRUE,
      # FOR FUTURE: Care Home removed, here's the code: .data$recid == "CH" & age >= 65
      frail =
        .data$recid %in% c("01B", "GLS", "50B", "02B", "04B", "AE2") &
          (rowSums(dplyr::across(
            c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
            ~ stringr::str_sub(.x, 1, 2) %in%
              c("W0", "W1")
          )) > 0 |
            rowSums(dplyr::across(
              c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
              ~ stringr::str_sub(.x, 1, 3) %in%
                c("F00", "F01", "F02", "F03", "F05", "I61", "I63", "I64", "G20", "G21")
            )) > 0 |
            rowSums(dplyr::across(
              c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
              ~ stringr::str_sub(.x, 1, 4) %in%
                c("R268", "G22X")
            )) > 0 |
            .data$spec == "AB" |
            .data$sigfac %in% c("1E", "1D") |
            .data$recid == "GLS"),

      # Maternity classification
      maternity = .data$recid == "02B",

      # High CC classification
      # FOR FUTURE: PhysicalandSensoryDisabilityClientGroup or LearningDisabilityClientGroup = "Y",
      # then high_cc_cohort = TRUE
      # FOR FUTURE: Care home removed, here's the code: .data$recid = "CH" & age < 65
      high_cc =
        rowSums(
          dplyr::across(
            c(.data$dementia, .data$hefailure, .data$refailure, .data$liver, .data$cancer)
          ),
          na.rm = TRUE
        ) >= 1 |
          .data$spec == "G5",

      # Medium CC classification
      medium_cc = rowSums(
        dplyr::across(
          c(.data$cvd, .data$copd, .data$chd, .data$parkinsons, .data$ms)
        ),
        na.rm = TRUE
      ) >= 1,

      # Low CC classification
      low_cc = rowSums(
        dplyr::across(
          c(.data$epilepsy, .data$asthma, .data$arth, .data$diabetes, .data$atrialfib)
        ),
        na.rm = TRUE
      ) >= 1,

      # Note from SPSS: we could add CMH here

      # Assisted living in the Community
      # Not using this cohort until we have more datasets and Scotland complete DN etc.
      # Code: .data$recid %in% c('HC-', 'HC + ', "RSP", "DN", "MLS", "INS", "CPL", "DC")
      comm_living = FALSE,

      # Seperate out prescribing cost for major conditions
      prescribing_cost = dplyr::if_else(.data$recid == "PIS", .data$cost_total_net, 0),

      # Adult Major Conditions classification
      adult_major = .data$age >= 18 & (.data$prescribing_cost >= 500 | .data$recid == "01B"),

      # Child Major Conditions classification
      child_major = .data$age < 18 & (.data$prescribing_cost >= 500 | .data$recid == "01B"),

      # Make sure any cohorts not assigned return FALSE
      dplyr::across(.data$mh:.data$child_major, ~ tidyr::replace_na(., FALSE))
    )

  return(return_data)
}

#' Assign End of Life cohort based on death codes
#'
#' @param data A data frame containing recid and the eleven death diagnosis variables
#'
#' @return A data frame with variables for external causes of death and members of the EoL cohort
#'
#' @family Demographic and Service Use Cohort functions
assign_eol_cohort <- function(data) {
  check_variables_exist(data, variables = c(
    "recid", "deathdiag1", "deathdiag2", "deathdiag3", "deathdiag4", "deathdiag5",
    "deathdiag6", "deathdiag7", "deathdiag8", "deathdiag9", "deathdiag10",
    "deathdiag11"
  ))

  external_deaths <- c(
    # Codes V01 to V99
    glue::glue("V{stringr::str_pad(1:99, 2, 'left', '0')}"),
    # Codes W00 to W99
    glue::glue("W{stringr::str_pad(0:99, 2, 'left', '0')}"),
    # Codes X00 to X99
    glue::glue("X{stringr::str_pad(0:99, 2, 'left', '0')}"),
    # Codes Y00 to Y84
    glue::glue("Y{stringr::str_pad(0:84, 2, 'left', '0')}")
  )
  # Codes W00 to W19
  falls_codes <- c(glue::glue("W{stringr::str_pad(0:19, 2, 'left', '0')}"))

  # External causes will be those codes that are in external_codes but are not in falls_codes
  return_data <- data %>% dplyr::mutate(
    external_cause = dplyr::if_else(
      rowSums(dplyr::across(dplyr::contains("deathdiag"), ~ stringr::str_sub(.x, 1, 3)
      %in% external_deaths)) > 0 &
        rowSums(dplyr::across(dplyr::contains("deathdiag"), ~ stringr::str_sub(.x, 1, 3)
        %in% falls_codes)) == 0, TRUE, NA
    ),
    # End of life cohort are records from NRS that are not external causes
    end_of_life = .data$recid == "NRS" & is.na(.data$external_cause)
  )
}

#' Assign substance misuse cohort
#'
#' @param data A data frame containing at least recid and the six diagnosis codes
#'
#' @return A data frame with five additional variables relating to substance misuse
#'
#' @family Demographic and Service Use Cohort functions
assign_substance_cohort <- function(data) {
  check_variables_exist(data,
    variables =
      c("recid", "diag1", "diag2", "diag3", "diag4", "diag5", "diag6")
  )

  return_data <- data %>%
    dplyr::mutate(
      substance_cohort =
      # FOR FUTURE, DrugsandAlcoholClientGroup = 'Y'
      # Alcohol codes
        .data$recid %in% c("01B", "GLS", "50B", "02B", "04B", "AE2") &
          rowSums(dplyr::across(
            c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
            ~ stringr::str_sub(.x, 1, 3) %in%
              c("F10", "K70", "X45", "X65", "Y15", "Y90", "Y91")
          )) > 0 |
          # Drug codes
          .data$recid %in% c("01B", "GLS", "50B", "02B", "04B", "AE2") &
            rowSums(dplyr::across(
              c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
              ~ stringr::str_sub(.x, 1, 4) %in%
                c(
                  "E244", "E512", "G312", "G621", "G721", "I426", "K292", "K860", "O354", "P043",
                  "Q860", "T510", "T511", "T519", "Y573", "R780", "Z502", "Z714", "Z721", "K852"
                )
            )) > 0,
      # Some drug codes only count If other code present in CIJ
      # i.e. T402/T404 only If F11 and T424 only If F13.
      f11 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
          ~ stringr::str_sub(.x, 1, 3) %in% c("F11")
        )) > 0,
      f13 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
          ~ stringr::str_sub(.x, 1, 3) %in% c("F13")
        )) > 0,
      t402_t404 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
          ~ stringr::str_sub(.x, 1, 4) %in% c("T402", "T404")
        )) > 0,
      t424 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
          ~ stringr::str_sub(.x, 1, 4) %in% c("T424")
        )) > 0
    )
  return(return_data)
}
