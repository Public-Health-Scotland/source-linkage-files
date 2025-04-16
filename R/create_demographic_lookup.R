#' Create the Demographic Cohort lookup
#'
#' @param data A data frame with the required variables.
#' @param year The year in standard SLF format.
#' @param update The update to use.
#' @param write_to_disk Default `TRUE`, will write the lookup to the
#' Cohorts folder defined by [get_slf_dir].
#'
#' @return The Demographics Cohorts lookup
#'
#' @family Demographic and Service Use Cohort functions
create_demographic_cohorts <- function(
    data,
    year,
    update = latest_update(),
    write_to_disk = TRUE) {
  check_variables_exist(
    data,
    c(
      "anon_chi",
      "cij_marker",
      "recid",
      "diag1",
      "diag2",
      "diag3",
      "diag4",
      "diag5",
      "diag6",
      "age",
      "sigfac",
      "spec",
      "dementia",
      "hefailure",
      "refailure",
      "liver",
      "cancer",
      "cvd",
      "copd",
      "chd",
      "parkinsons",
      "ms",
      "epilepsy",
      "asthma",
      "arth",
      "diabetes",
      "atrialfib",
      "cost_total_net",
      "deathdiag1",
      "deathdiag2",
      "deathdiag3",
      "deathdiag4",
      "deathdiag5",
      "deathdiag6",
      "deathdiag7",
      "deathdiag8",
      "deathdiag9",
      "deathdiag10",
      "deathdiag11"
    )
  )

  demo_lookup <- data %>%
    # Remove missing chi
    dplyr::filter(!is_missing(.data$anon_chi)) %>%
    # Add the various cohorts
    dplyr::mutate(
      mh = assign_d_cohort_mh(
        .data$recid,
        .data$diag1,
        .data$diag2,
        .data$diag3,
        .data$diag4,
        .data$diag5,
        .data$diag6
      ),
      frail = assign_d_cohort_frailty(
        .data$recid,
        .data$diag1,
        .data$diag2,
        .data$diag3,
        .data$diag4,
        .data$diag5,
        .data$diag6,
        .data$spec,
        .data$sigfac
      ),
      maternity = assign_d_cohort_maternity(
        .data$recid
      ),
      high_cc = assign_d_cohort_high_cc(
        .data$dementia,
        .data$hefailure,
        .data$refailure,
        .data$liver,
        .data$cancer,
        .data$spec
      ),
      medium_cc = assign_d_cohort_medium_cc(
        .data$cvd,
        .data$copd,
        .data$chd,
        .data$parkinsons,
        .data$ms
      ),
      low_cc = assign_d_cohort_low_cc(
        .data$epilepsy,
        .data$asthma,
        .data$arth,
        .data$diabetes,
        .data$atrialfib
      ),
      comm_living = assign_d_cohort_comm_living(),
      adult_major = assign_d_cohort_adult_major(
        .data$recid,
        .data$age,
        .data$cost_total_net
      ),
      child_major = assign_d_cohort_child_major(
        .data$recid,
        .data$age,
        .data$cost_total_net
      ),
      end_of_life = assign_d_cohort_eol(
        .data$recid,
        .data$deathdiag1,
        .data$deathdiag2,
        .data$deathdiag3,
        .data$deathdiag4,
        .data$deathdiag5,
        .data$deathdiag6,
        .data$deathdiag7,
        .data$deathdiag8,
        .data$deathdiag9,
        .data$deathdiag10,
        .data$deathdiag11
      )
    ) %>%
    assign_d_cohort_substance() %>%
    # Aggregate to CHI level
    dplyr::group_by(.data$anon_chi) %>%
    dplyr::summarise(dplyr::across(c(
      "mh",
      "frail",
      "maternity",
      "high_cc",
      "medium_cc",
      "low_cc",
      "comm_living",
      "adult_major",
      "child_major",
      "end_of_life",
      "substance"
    ), any)) %>%
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
    dplyr::relocate(.data$demographic_cohort, .after = .data$anon_chi)

  # Write to disk
  if (write_to_disk) {
    write_file(demo_lookup,
      path = get_demographic_cohorts_path(year, update, check_mode = "write"),
      group_id = 3206 # hscdiip owner
    )
  }

  return(demo_lookup)
}

#' Assign Mental Health cohort
#'
#' @description A record is considered to be in the MH cohort if the
#' recid is 04B. Also, if the recid is one of 01B, GLS, 50B, 02B or AE2
#' \strong{and} any of the diagnosis codes start with F2, F3, F067, F070, F072,
#'  F078, or F079.
#'
#' @rdname assign_demographic_cohorts
#'
#' @param recid A vector of record IDs
#' @param diag1,diag2,diag3,diag4,diag5,diag6
#' Character vectors of ICD-10 diagnosis codes.
#'
#' @return A boolean vector indicating whether a record is in the particular
#' demographic cohort.
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_mh <- function(recid,
                               diag1,
                               diag2,
                               diag3,
                               diag4,
                               diag5,
                               diag6) {
  mh <-
    # FOR FUTURE: when variable MentalHealthProblemsClientGroup exists and is "Y", mh_cohort = TRUE
    dplyr::case_when(
      recid == "04B" ~ TRUE,
      recid %in% c("01B", "GLS", "50B", "02B", "AE2") &
        (rowSums(dplyr::across(
          c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
          ~ stringr::str_starts(
            .x,
            paste(
              "F2",
              "F3",
              "F067",
              "F070",
              "F072",
              "F078",
              "F079",
              sep = "|"
            )
          )
        ), na.rm = TRUE) > 0L) ~ TRUE,
      TRUE ~ FALSE
    )

  return(mh)
}

#' Assign Frailty cohort
#' @description A record is considered to be in the frailty cohort if:
#' \itemize{
#'     \item The recid is 01B, 50B, 02B, 04B or AE2 \strong{and}
#'     \enumerate{
#'         \item One of the diagnosis codes starts with W0 or W1
#'         \item One of the diagnosis codes starts with F00, F01, F02, F03, F05,
#'          I61, I63, I64, G20 or G21
#'         \item One of the diagnosis codes starts with R268 or G22X
#'         \item The specialty is AB
#'         \item The significant facility is 1E or 1D
#'         \item The recid is GLS}
#'    }
#'
#' @rdname assign_demographic_cohorts
#' @param spec A vector of specialty codes
#' @param sigfac A vector of significant facilities
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_frailty <- function(recid,
                                    diag1,
                                    diag2,
                                    diag3,
                                    diag4,
                                    diag5,
                                    diag6,
                                    spec,
                                    sigfac) {
  frail <-
    # FOR FUTURE: when variable ElderlyFrailClientGroup exists and is "Y", frail_cohort = TRUE,
    # FOR FUTURE: Care Home removed, here's the code: .data$recid == "CH" & age >= 65
    dplyr::case_when(
      recid == "GLS" ~ TRUE,
      recid %in% c(
        "01B",
        "50B",
        "02B",
        "04B",
        "AE2"
      ) & spec == "AB" ~ TRUE,
      recid %in% c(
        "01B",
        "50B",
        "02B",
        "04B",
        "AE2"
      ) & sigfac %in% c("1E", "1D") ~ TRUE,
      recid %in% c(
        "01B",
        "50B",
        "02B",
        "04B",
        "AE2"
      ) &
        (rowSums(dplyr::across(
          c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
          ~ stringr::str_starts(.x, paste(
            "W0",
            "W1",
            "F00",
            "F01",
            "F02",
            "F03",
            "F05",
            "I61",
            "I63",
            "I64",
            "G20",
            "G21",
            "R268",
            "G22X",
            sep = "|"
          ))
        ), na.rm = TRUE) > 0L) ~ TRUE,
      TRUE ~ FALSE
    )
  return(frail)
}

#' Assign Maternity cohort
#' @description A record is considered to be in the Maternity cohort if the recid
#' is 02B
#'
#' @rdname assign_demographic_cohorts
#'
#' @param recid A vector of recids
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_maternity <- function(recid) {
  maternity <- recid == "02B"
  return(maternity)
}

#' Assign High Complex Conditions cohort
#' @description A record is considered to be in the High Complex Conditions
#' cohort if the patient has any of the listed LTCs, or the specialty is G5
#'
#' @rdname assign_demographic_cohorts
#'
#' @param dementia A vector of dementia LTC flags
#' @param hefailure A vector of heart failure LTC flags
#' @param refailure A vector of renal failure LTC flags
#' @param liver A vector of liver disease LTC flags
#' @param cancer A vector of cancer LTC flags
#' @param spec A vector of specialties
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_high_cc <- function(dementia,
                                    hefailure,
                                    refailure,
                                    liver,
                                    cancer,
                                    spec) {
  high_cc <- dplyr::case_when(
    spec == "G5" ~ TRUE,
    # FOR FUTURE: PhysicalandSensoryDisabilityClientGroup or LearningDisabilityClientGroup = "Y",
    # then high_cc_cohort = TRUE
    # FOR FUTURE: Care home removed, here's the code: .data$recid = "CH" & age < 65
    (rowSums(dplyr::pick(c(
      "dementia",
      "hefailure",
      "refailure",
      "liver",
      "cancer"
    )), na.rm = TRUE) >= 1L) ~ TRUE,
    .default = FALSE
  )

  return(high_cc)
}

#' Assign Medium Complex Conditions cohort
#' @description A record is considered to be in the Medium Complex Conditions
#' cohort if the patient has any of the listed LTCs
#'
#' @rdname assign_demographic_cohorts
#'
#' @param cvd A vector of CVD LTC flags
#' @param copd A vector of COPD LTC flags
#' @param chd A vector of CHD LTC flags
#' @param parkinsons A vector of Parkinson's LTC flags
#' @param ms A vector of MS LTC flags
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_medium_cc <- function(cvd, copd, chd, parkinsons, ms) {
  medium_cc <-
    rowSums(dplyr::pick(c(
      "cvd",
      "copd",
      "chd",
      "parkinsons",
      "ms"
    )), na.rm = TRUE) >= 1L
  return(medium_cc)
}

#' Assign Low Complex Conditions cohort
#' @description A record is considered to be in the Low Complex Conditions
#' cohort if the patient has any of the listed LTCs.
#'
#' @rdname assign_demographic_cohorts
#'
#' @param epilepsy A vector of epilepsy LTC flags
#' @param asthma A vector of asthma LTC flags
#' @param arth A vector of arthritis LTC flags
#' @param diabetes A vector of diabetes LTC flags
#' @param atrialfib A vector of atrial fibrillation LTC flags
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_low_cc <- function(epilepsy,
                                   asthma,
                                   arth,
                                   diabetes,
                                   atrialfib) {
  low_cc <-
    rowSums(dplyr::pick(c(
      "epilepsy",
      "asthma",
      "arth",
      "diabetes",
      "atrialfib"
    )), na.rm = TRUE) >= 1L
  return(low_cc)
}

#' Assign Assisted living in the Community cohort
#' @description Not using this cohort until we have more datasets and Scotland
#' complete DN etc. so will always return FALSE.
#'
#' @rdname assign_demographic_cohorts
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_comm_living <- function() {
  # Code: recid %in% c("HC", "RSP", "DN", "MLS", "INS", "CPL", "DC")
  comm_living <- FALSE
  return(comm_living)
}

#' Assign Adult Major Conditions cohort
#' @description A person is considered to be in this cohort if their age is over 18 and
#' the recid is 01B, or their prescribing cost is £500 or over
#'
#' @rdname assign_demographic_cohorts
#'
#' @param age A vector of ages
#' @param cost_total_net A vector of total net costs
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_adult_major <- function(recid, age, cost_total_net) {
  adult_major <- age >= 18L & ((cost_total_net >= 500.0 & recid == "PIS") | recid == "01B")
  return(adult_major)
}

#' Assign Child Major Conditions cohort
#' @description A person is considered to be in this cohort if their age is under 18 and
#' the recid is 01B, or their prescribing cost is £500 or over
#'
#' @rdname assign_demographic_cohorts
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_child_major <- function(recid, age, cost_total_net) {
  child_major <- age < 18L & (cost_total_net >= 500.0 & recid == "PIS" | recid == "01B")
  return(child_major)
}

#' Assign End of Life cohort
#' @description A record is considered to be in the EoL cohort if it is an NRS death record
#' and the cause of death is not external. The exception to this is if the cause of death is external
#' and is classified as a fall
#'
#' @rdname assign_demographic_cohorts
#'
#' @param deathdiag1,deathdiag2,deathdiag3,deathdiag4,deathdiag5,deathdiag6,deathdiag7,deathdiag8,deathdiag9,deathdiag10,deathdiag11
#' Character vectors of ICD-10 death diagnosis codes.
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_eol <- function(recid,
                                deathdiag1,
                                deathdiag2,
                                deathdiag3,
                                deathdiag4,
                                deathdiag5,
                                deathdiag6,
                                deathdiag7,
                                deathdiag8,
                                deathdiag9,
                                deathdiag10,
                                deathdiag11) {
  external_deaths <- c(
    # Codes V01 to V99
    stringr::str_glue("V{stringr::str_pad(1:99, 2, 'left', '0')}"),
    # Codes W00 to W99
    stringr::str_glue("W{stringr::str_pad(0:99, 2, 'left', '0')}"),
    # Codes X00 to X99
    stringr::str_glue("X{stringr::str_pad(0:99, 2, 'left', '0')}"),
    # Codes Y00 to Y84
    stringr::str_glue("Y{stringr::str_pad(0:84, 2, 'left', '0')}")
  )

  # Codes W00 to W19
  falls_codes <- c(stringr::str_glue("W{stringr::str_pad(0:19, 2, 'left', '0')}"))

  # External causes will be those codes that are in external_codes but are not in falls_codes
  external_cause <-
    rowSums(
      dplyr::across(dplyr::contains("deathdiag"), ~ stringr::str_sub(.x, 1L, 3L)
      %in% external_deaths)
    ) > 0L &
      rowSums(
        dplyr::across(dplyr::contains("deathdiag"), ~ stringr::str_sub(.x, 1L, 3L)
        %in% falls_codes)
      ) == 0L

  # End of life cohort are records from NRS that are not external causes
  end_of_life <- recid == "NRS" & external_cause == FALSE

  return(end_of_life)
}

#' Assign substance misuse cohort
#'
#' @description Please see technical documentation for full description of
#' the Substance Misuse cohort
#'
#' @rdname assign_demographic_cohorts
#'
#' @param data A data frame containing at least `recid`` and the six diagnosis
#' codes (`diag`:`diag6`)
#'
#' @return A data frame with an additional boolean variable, `substance`,
#' indicating a record is in the substance misuse cohort.
#'
#' @family Demographic and Service Use Cohort functions
assign_d_cohort_substance <- function(data) {
  check_variables_exist(data,
    variables =
      c("recid", "diag1", "diag2", "diag3", "diag4", "diag5", "diag6")
  )

  return_data <- data %>%
    dplyr::mutate(
      substance =
      # FOR FUTURE, DrugsandAlcoholClientGroup = 'Y'
      # Alcohol codes
        .data$recid %in% c("01B", "GLS", "50B", "02B", "04B", "AE2") &
          rowSums(dplyr::across(
            c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
            ~ stringr::str_starts(.x, paste(
              "F10",
              "K70",
              "X45",
              "X65",
              "Y15",
              "Y90",
              "Y91",
              "E244",
              "E512",
              "G312",
              "G621",
              "G721",
              "I426",
              "K292",
              "K860",
              "O354",
              "P043",
              "Q860",
              "T510",
              "T511",
              "T519",
              "Y573",
              "R780",
              "Z502",
              "Z714",
              "Z721",
              "K852",
              sep = "|"
            ))
          ), na.rm = TRUE) > 0L |
          # Drug codes
          .data$recid %in% c("01B", "04B") &
            rowSums(dplyr::across(
              c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
              ~ stringr::str_starts(.x, paste(
                "F11",
                "F12",
                "F13",
                "F14",
                "F15",
                "F16",
                "F18",
                "F19",
                "T400",
                "T401",
                "T403",
                "T405",
                "T406",
                "T407",
                "T408",
                "T409",
                "T436",
                sep = "|"
              ))
            ), na.rm = TRUE) > 0L,
      # Some drug codes only count If other code present in CIJ
      # i.e. T402/T404 only If F11 and T424 only If F13.
      f11 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
          ~ stringr::str_sub(.x, 1L, 3L) %in% "F11"
        )) > 0L,
      f13 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
          ~ stringr::str_sub(.x, 1L, 3L) %in% "F13"
        )) > 0L,
      t402_t404 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
          ~ stringr::str_sub(.x, 1L, 4L) %in% c("T402", "T404")
        )) > 0L,
      t424 = .data$recid %in% c("01B", "04B") &
        rowSums(dplyr::across(
          c("diag1", "diag2", "diag3", "diag4", "diag5", "diag6"),
          ~ stringr::str_sub(.x, 1L, 4L) %in% "T424"
        )) > 0L
    ) %>%
    # Aggregate to CIJ level
    dplyr::group_by(.data$anon_chi, .data$cij_marker) %>%
    dplyr::summarise(
      dplyr::across("mh":"t424", ~ any(.x))
    ) %>%
    dplyr::ungroup() %>%
    # Assign drug and alcohol misuse
    dplyr::mutate(substance = dplyr::if_else(
      (.data$f11 & .data$t402_t404) | (.data$f13 & .data$t424),
      TRUE,
      .data$substance
    )) %>%
    dplyr::select(-"f11", -"f13", -"t402_t404", -"t424")

  return(return_data)
}
