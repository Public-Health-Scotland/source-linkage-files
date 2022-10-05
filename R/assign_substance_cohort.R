tester <- tibble::tribble(
  ~recid, ~diag1, ~diag2, ~diag3, ~diag4, ~diag5, ~diag6,
  # Alcohol
  "01B", "F10", NA, NA, NA, NA, NA,
  "GLS", "A24", NA, NA, "X45", NA, NA,
  # Drug
  "50B", "A24", "T510", NA, NA, NA, NA,
  "AE2", NA, NA, NA, "Z721", NA, NA,
  # False
  "01B", NA, NA, NA, NA, NA, NA,
  "GLS", NA, NA, "T512", NA, NA, NA,
  # F11
  "01B", "F11", NA, NA, NA, NA, NA,
  # F13
  "04B", "A24", "F13", NA, NA, NA, NA,
  # T402, T404
  "01B", NA, NA, NA, "T402", NA, NA,
  "04B", NA, NA, "T404", NA, NA, NA,
  # T424
  "01B", NA, "T424", NA, NA, NA, NA,
  # F11 and T202/404
  "01B", "F11", "T402", NA, NA, NA, NA,
  "04B", NA, NA, "F11", NA, "T404", NA,
  "01B", "T402", NA, NA, NA, "F11", NA,
  # F13 and T424
  "04B", "F13", "T424", NA, NA, NA, NA
)


return_data <- tester %>%
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
