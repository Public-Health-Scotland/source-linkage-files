#' Link AE episodes released from CH
#'
#' @description 1. Add two variable, sc_ch_link_ae and sc_ch_link_adms,
#' for CH episode to indicate discharge to AE2 and (01B, 04B, GLS) seperatively.
#' 2. Populate ch_name and ch_postcode to relavent AE episodes from CH episodes
#'
#' @param ep episode file
link_ch_with_adms <- function(ep) {
  # to fix no visible binding for global variable
  x <- y <- NULL

  ep <- ep %>%
    dplyr::mutate(ep_row_id_CE = dplyr::row_number())

  data <- ep %>%
    dplyr::select(
      "ep_row_id_CE",
      "anon_chi",
      "recid",
      "record_keydate1",
      "record_keydate2",
      "keytime1",
      "keytime2",
      "ch_name",
      "ch_postcode",
      "cup_pathway",
      "cij_pattype",
      "cij_ipdc",
      "cij_start_date"
    )

  # pull care home data
  care_home_data <- data %>%
    dplyr::filter(.data$recid == "CH") %>%
    dplyr::arrange(.data$anon_chi, .data$record_keydate1)

  # populate ch_name and ch_postcode from care home to ae episodes ...
  # ... if someone goes to ae from ch
  adms <- data %>%
    # c("01B", "04B", "GLS", "AE2") are included to link with CH.
    # Technically, DD episodes can also be linked with CH episodes ...
    # ... as DD episodes are linked with AE episodes and others.
    dplyr::filter(.data$recid %in% c("01B", "04B", "GLS", "AE2")) %>%
    # remove A&E records that don't lead to an admission,
    # remove elective admissions,
    # and remove day cases
    dplyr::filter(.data$recid == "AE2" &
                    grepl("A", .data$cup_pathway) == TRUE |
                    .data$recid != "AE2") %>%
    dplyr::filter(!(.data$recid != "AE2" &
                      .data$cij_pattype == "Elective")) %>%
    dplyr::filter(!(.data$recid != "AE2" &
                      .data$cij_ipdc == "D")) %>%
    dplyr::arrange(
      .data$anon_chi,
      .data$record_keydate1,
      .data$keytime1,
      .data$record_keydate2,
      .data$keytime2
    ) %>%
    # add a new variable that is equal to the cij start date or the A&E attendance date -
    # ..... this is the date we want to test against the two care home dates
    dplyr::mutate(test_date = dplyr::coalesce(.data$cij_start_date, .data$record_keydate2))
  # populate with care home data ...
  # ... if the test_date falls within the care home window

  # link ch to ae
  link_ae <- adms %>%
    dplyr::filter(.data$recid == "AE2") %>%
    dplyr::inner_join(
      care_home_data,
      by = dplyr::join_by(
        x$anon_chi == y$anon_chi,
        x$test_date > y$record_keydate1,
        x$test_date < y$record_keydate2
      ),
      na_matches = "never",
      unmatched = "drop",
      multiple = "first",
      suffix = c("", ".y")
    ) %>%
    dplyr::mutate(
      ch_name = dplyr::coalesce(.data$ch_name, .data$ch_name.y),
      ch_postcode = dplyr::coalesce(.data$ch_postcode, .data$ch_postcode.y)
    ) %>%
    dplyr::select(-c(dplyr::ends_with(".y"), "test_date")) %>%
    dplyr::mutate(sc_ch_link_ae = 1L, sc_ch_link_adms = NA)

  # link ch to 01b, 04b, gls
  link_adms <- adms %>%
    dplyr::filter(.data$recid %in% c("01B", "04B", "GLS")) %>%
    dplyr::inner_join(
      care_home_data,
      by = dplyr::join_by(
        x$anon_chi == y$anon_chi,
        x$test_date > y$record_keydate1,
        x$test_date < y$record_keydate2
      ),
      na_matches = "never",
      unmatched = "drop",
      multiple = "first",
      suffix = c("", ".y")
    ) %>%
    dplyr::mutate(
      ch_name = dplyr::coalesce(.data$ch_name, .data$ch_name.y),
      ch_postcode = dplyr::coalesce(.data$ch_postcode, .data$ch_postcode.y)
    ) %>%
    dplyr::select(-c(dplyr::ends_with(".y"), "test_date")) %>%
    dplyr::mutate(sc_ch_link_adms = 1L, sc_ch_link_ae = NA)


  # Now update ch_name and ch_postcode values in ep from link_ae
  ep <- ep %>%
    dplyr::left_join(
      rbind(link_ae, link_adms) %>%
        dplyr::select(
          "ep_row_id_CE",
          "ch_name",
          "ch_postcode",
          "sc_ch_link_ae",
          "sc_ch_link_adms"
        ),
      by = "ep_row_id_CE",
      suffix = c("", ".y")
    ) %>%
    dplyr::mutate(
      ch_name = dplyr::coalesce(.data$ch_name, .data$ch_name.y),
      ch_postcode = dplyr::coalesce(.data$ch_postcode, .data$ch_postcode.y)
    ) %>%
    dplyr::select(-"ep_row_id_CE", -tidyselect::ends_with(".y")) %>%
    # Standardise sc_ch_link_ae, sc_ch_link_adms.
    # `sc_ch_link_ae` should be:
    #   1L if someone goes to ae from ch, (recid == AE)
    #   0L if someone goes to ae but not from ch, (recid == AE)
    #   NA if recid != AE, meaning this variable does not apply
    dplyr::mutate(
      sc_ch_link_ae = dplyr::if_else((
        is.na(.data$sc_ch_link_ae) &
          .data$recid == "AE2"
      ), 0L, .data$sc_ch_link_ae),
      sc_ch_link_adms = dplyr::if_else((
        is.na(.data$sc_ch_link_adms) &
          .data$recid %in% c("01B", "04B", "GLS")
      ), 0L, .data$sc_ch_link_adms)
    )

  cli::cli_alert_info("Link CH to AE2 function finished at {Sys.time()}")

  return(ep)
}
