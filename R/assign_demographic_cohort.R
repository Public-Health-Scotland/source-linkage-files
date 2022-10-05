#' Assign the service use cohort variables
#'
#' @param data A data frame with the required variables for assignment
#'
#' @return A data frame with ten additional variables relating to the different cohorts
#' @export
#'
#' @family Demographic and Service Use Cohort functions
assign_service_use_cohort <- function(data) {
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
      mh_cohort =
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
      frail_cohort =
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
      maternity_cohort = .data$recid == "02B",

      # High CC classification
      # FOR FUTURE: PhysicalandSensoryDisabilityClientGroup or LearningDisabilityClientGroup = "Y",
      # then high_cc_cohort = TRUE
      # FOR FUTURE: Care home removed, here's the code: .data$recid = "CH" & age < 65
      high_cc_cohort =
        purrr::reduce(dplyr::select(
          .,
          .data$dementia, .data$hefailure, .data$refailure, .data$liver, .data$cancer
        ), `|`) |
          .data$spec == "G5",

      # Medium CC classification
      medium_cc_cohort = purrr::reduce(dplyr::select(
        .,
        .data$cvd, .data$copd, .data$chd, .data$parkinsons, .data$ms
      ), `|`),

      # Low CC classification
      low_cc_cohort = purrr::reduce(dplyr::select(
        .,
        .data$epilepsy, .data$asthma, .data$arth, .data$diabetes, .data$atrialfib
      ), `|`),

      # Note from SPSS: we could add CMH here

      # Assisted living in the Community
      # Not using this cohort until we have more datasets and Scotland complete DN etc.
      # Code: .data$recid %in% c('HC-', 'HC + ', "RSP", "DN", "MLS", "INS", "CPL", "DC")
      comm_living_cohort = FALSE,

      # Seperate out prescribing cost for major conditions
      prescribing_cost = dplyr::if_else(.data$recid == "PIS", .data$cost_total_net, 0),

      # Adult Major Conditions classification
      adult_major_cohort = .data$age >= 18 & (.data$prescribing_cost >= 500 | .data$recid == "01B"),

      # Child Major Conditions classification
      child_major_cohort = .data$age < 18 & (.data$prescribing_cost >= 500 | .data$recid == "01B"),

      # Make sure any cohorts not assigned return FALSE
      dplyr::across(mh_cohort:child_major_cohort, ~ tidyr::replace_na(., FALSE))
    )

  return(return_data)
}
