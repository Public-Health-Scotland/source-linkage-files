#' Add Potentially Preventable Admission (PPA) Marker
#'
#' @description This function takes a data frame input and determines, based on
#' a combination of diagnostic codes and operation codes, whether an admission
#' was preventable or not.
#' @param data A data frame
#'
#' @return A data frame to use as a lookup of PPAs
#' @export
add_ppa_flag <- function(data) {
  check_variables_exist(data, variables = c(
    "chi", "cij_marker", "cij_pattype", "recid",
    "op1a", "diag1", "diag2", "diag3", "diag4",
    "diag5", "diag6"
  ))

  if (!(any(data$recid %in% c("01B", "02B", "04B", "GLS")))) {
    nrecids <- length(unique(data$recid))
    cli::cli_abort("None of the {nrecids} recid{?s} provided will relate to PPAs, and the function
                   will abort.")
  }

  matching_data <- data %>%
    # Select out only the columns we need
    dplyr::select(
      .data$chi, .data$cij_marker, .data$cij_pattype, .data$recid,
      .data$op1a, .data$diag1, .data$diag2, .data$diag3, .data$diag4,
      .data$diag5, .data$diag6
    ) %>%
    # Filter only recids and patient type where admission was preventable
    dplyr::filter(.data$recid %in% c("01B", "02B", "04B", "GLS") & .data$cij_pattype == "Non-Elective") %>%
    # We only want the first record in each cij, and we want to exclude empty cij and empty chi
    dplyr::group_by(.data$chi, .data$cij_marker) %>%
    dplyr::filter(dplyr::row_number() == 1 & !is.na(.data$cij_marker) & !is.na(.data$chi)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      # Extract some characters from diagnosis codes for easier reading below
      diag1_3char = stringr::str_sub(.data$diag1, 1, 3),
      diag1_4char = stringr::str_sub(.data$diag1, 1, 4),
      op1a_3char = stringr::str_sub(.data$op1a, 1, 3),

      # Excluding operations are op1a codes from K01 to K50, K56, K60, and K61 (dental)
      excluding_operation = .data$op1a_3char %in%
        c(glue::glue("K{stringr::str_pad(1:50, 2, 'left', '0')}"), "K56", "K60", "K61"),

      # Adding ppa flag
      ppa = dplyr::case_when(
        # Just reliant on diag1, first 3 characters
        diag1_3char %in%
          c(
            # ENT
            "H66", "J06",
            # Dental
            "K02", "K03", "K04", "K05", "K06", "K08",
            # Convulsions
            "G40", "G41", "R56", "O15",
            # Nutrient deficiency
            "E40", "E41", "E43",
            # Dehydration
            "E86",
            # Nephritis
            "N10", "N11", "N12",
            # Pelvic
            "N70", "N73",
            # Asthma
            "J45", "J46",
            # Copd
            "J41", "J42", "J43", "J44", "J47"
          ) ~ TRUE,

        # Just reliant on diag1, first four characters
        diag1_4char %in%
          c(
            # ENT
            "J028", "J029", "J038", "J039", "J321",
            # Nutrient deficiency
            "E550", "E643", "M833",
            # Dehydration
            "K522", "K528", "K529",
            # Perforated ulcer
            "K250", "K251", "K252", "K254", "K255", "K256", "K260", "K261",
            "K262", "K264", "K265", "K266", "K270", "K271", "K272", "K274",
            "K275", "K276", "K280", "K281", "K282", "K284", "K285", "K286",
            # Iron deficiency
            "D501", "D508", "D509"
          ) ~ TRUE,

        # Reliant on any of the six diagnosis codes, first three characters
        rowSums(dplyr::across(
          c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
          ~ stringr::str_sub(.x, 1, 3) %in%
            c(
              # Gangrene
              "R02",
              # Influenza
              "J10", "J11", "J13",
              # Vaccine-preventable
              "A35", "A36", "A80", "B05", "B06", "B26"
            )
        )) > 0 ~ TRUE,

        # Reliant on any of the six diagnosis codes, first four characters
        rowSums(dplyr::across(
          c(.data$diag1, .data$diag2, .data$diag3, .data$diag4, .data$diag5, .data$diag6),
          ~ stringr::str_sub(.x, 1, 4) %in%
            c(
              # Vaccine-preventable
              "A370", "A379", "B161", "B169",
              # Diabetes
              "E100", "E101", "E102", "E103", "E104",
              "E105", "E106", "E107", "E108", "E110",
              "E111", "E112", "E113", "E114", "E115",
              "E116", "E117", "E118", "E120", "E121",
              "E122", "E123", "E124", "E125", "E126",
              "E127", "E128", "E130", "E131", "E132",
              "E133", "E134", "E135", "E136", "E137",
              "E138", "E140", "E141", "E142", "E143",
              "E144", "E145", "E146", "E147", "E148",
              # Influenza
              "J181"
            )
        )) > 0 ~ TRUE,

        # Reliant on op1a and diag1
        # Angina
        diag1_3char == "I20" &
          !(.data$op1a_3char %in% c("K40", "K45", "K49", "K60", "K65", "K66")) ~ TRUE,
        # Cellulitis
        diag1_3char %in% c("L03", "L04") &
          !(.data$op1a_3char %in% c("S06", "S57", "S68", "S70", "W90", "X11")) ~ TRUE,
        diag1_4char %in% c("L080", "L088", "L089", "L980") &
          !(.data$op1a_3char %in% c("S06", "S57", "S68", "S70", "W90", "X11")) ~ TRUE,

        # Reliant on diag1 and excluding_operation
        diag1_3char %in% c(
          # Angina
          "I10",
          # Congestive HF
          "I50",
          "J81"
        ) &
          !excluding_operation ~ TRUE,
        diag1_4char %in% c(
          # Hypertension
          "I119", "I110"
        ) &
          !excluding_operation ~ TRUE,

        # Reliant on diag1 and diag2
        # Bronchitis
        diag1_3char == "J20" &
          stringr::str_sub(.data$diag2, 1, 3) %in% c("J41", "J42", "J43", "J44", "J47") ~ TRUE,

        # All other values
        TRUE ~ FALSE
      )
    ) %>%
    # Just select out the chi, cij marker and ppa for ease of joining
    dplyr::select(.data$chi, .data$cij_marker, `cij_ppa` = .data$ppa)

  # Match on the ppa lookup to original data
  ppa_cij_data <- dplyr::left_join(data, matching_data, by = c("chi", "cij_marker")) %>%
    dplyr::mutate(cij_ppa = dplyr::if_else(is.na(.data$cij_ppa), FALSE, .data$cij_ppa))

  return(ppa_cij_data)
}
