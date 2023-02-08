#' Create individual file
#'
#' @description Creates individual file from episode file
#'
#' @param episode_file Tibble containing episodic data
create_individual_file <- function(episode_file) {
  episode_file %>%
    remove_blank_chi() %>%
    find_non_duplicates(.data$cij_marker, "Distinct_CIJ") %>%
    add_cij_columns() %>%
    find_non_duplicates(.data$ch_chi_cis, "first_ch_ep") %>%
    add_all_columns()
}

#' Remove blank CHI
#'
#' @description Convert blank strings to NA and remove NAs from CHI column
#'
#' @inheritParams create_individual_file
remove_blank_chi <- function(episode_file) {
  episode_file %>%
    dplyr::mutate(chi = dplyr::na_if(.data$chi, "")) %>%
    dplyr::filter(!is.na(.data$chi))
}

#' Find non-duplicates
#'
#' @description Create new column which marks first (per group)
#' non-duplicated observation as 1, with any duplicates marked as 0.
#'
#' @inheritParams create_individual_file
#' @param group Column to group by
#' @param col_name Name of new column
find_non_duplicates <- function(episode_file, group, col_name) {
  episode_file %>%
    dplyr::group_by(.data$chi, {{ group }}) %>%
    dplyr::mutate("{col_name}" := dplyr::if_else(duplicated({{ group }}), 0, 1)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate("{col_name}" := dplyr::if_else(is.na({{ group }}), 0, .data[[col_name]]))
}

#' Add CIJ-related columns
#'
#' @description Add new columns related to CIJ
#'
#' @inheritParams create_individual_file
add_cij_columns <- function(episode_file) {
  episode_file %>%
    dplyr::mutate(
      CIJ_non_el = dplyr::if_else(.data$cij_pattype_code == 0,
        .data$Distinct_CIJ,
        NA_real_
      ),
      CIJ_el = dplyr::if_else(.data$cij_pattype_code == 1,
        .data$Distinct_CIJ,
        NA_real_
      ),
      CIJ_mat = dplyr::if_else(.data$cij_pattype_code == 2,
        .data$Distinct_CIJ,
        NA_real_
      )
    ) %>%
    dplyr::mutate(cij_delay = dplyr::if_else(
      (.data$cij_delay == 1 & .data$Distinct_CIJ == 1),
      1,
      0
    )) %>%
    dplyr::mutate(
      preventable_admissions = dplyr::if_else(
        (cij_ppa == 1 & Distinct_CIJ == 1),
        1,
        0
      ),
      preventable_beddays = dplyr::if_else(
        (cij_ppa == 1 & Distinct_CIJ == 1),
        as.numeric(cij_end_date - cij_start_date),
        0
      )
    )
}

#' Add all columns
#'
#' @description Add new columns based on SMRType and recid which follow a pattern
#' of prefixed column names created based on some condition.
#'
#' @inheritParams create_individual_filw
add_all_columns <- function(episode_file) {
  episode_file %>%
    add_acute_columns("Acute", (smrtype == "Acute-DC" | smrtype == "Acute-IP") & cij_pattype != "Maternity") %>%
    add_mat_columns("Mat", recid == "02B" | cij_pattype == "Maternity") %>%
    add_mh_columns("MH", recid == "04B" & cij_pattype != "Maternity") %>%
    add_gls_columns("GLS", smrtype == "GLS-IP") %>%
    add_op_columns("OP", recid == "00B") %>%
    add_ae_columns("AE", recid == "AE2") %>%
    add_pis_columns("PIS", recid == "PIS") %>%
    add_ooh_columns("OoH", recid == "OoH") %>%
    add_dn_columns("DN", recid == "DN") %>%
    add_cmh_columns("CMH", recid == "CMH") %>%
    add_dd_columns("DD", recid == "DD") %>%
    add_nsu_columns("NSU", recid == "NSU") %>%
    add_nrs_columns("NRS", recid == "NRS") %>%
    add_hl1_columns("HL1", recid == "HL1") %>%
    add_ch_columns("CH", recid == "CH") %>%
    add_hc_columns("HC", recid == "HC") %>%
    add_at_columns("AT", recid == "AT") %>%
    add_sds_columns("SDS", recid == "SDS")
}

#' Add Acute columns
#'
#' @inheritParams create_individuaL_file
#' @param prefix Prefix to add to related columns, e.g. "Acute"
#' @param condition Condition to create new columns based on
add_acute_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition)
}

#' Add Mat columns
#'
#' @inheritParams add_acute_columns
add_mat_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition, elective = FALSE)
}

#' Add MH columns
#'
#' @inheritParams add_acute_columns
add_mh_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition, ipdc_d = FALSE)
}

#' Add GLS columns
#'
#' @inheritParams add_acute_columns
add_gls_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition, ipdc_d = FALSE)
}

#' Add OP columns
#'
#' @inheritParams add_acute_columns
add_op_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file <- episode_file %>%
    add_standard_cols(prefix, condition)
  condition_1 <- substitute(condition & attendance_status == 1)
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_newcons_attendances" := dplyr::if_else(eval(condition_1), 1, NA_real_),
      "{prefix}_cost_attend" := dplyr::if_else(eval(condition_1), cost_total_net, NA_real_)
    )
  condition_5_8 <- substitute(condition & attendance_status %in% c(5, 8))
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_newcons_dnas" := dplyr::if_else(eval(condition_5_8), 1, NA_real_),
      "{prefix}_cost_dnas" := dplyr::if_else(eval(condition_5_8), cost_total_net_incdnas, NA_real_)
    )
  return(episode_file)
}

#' Add AE columns
#'
#' @inheritParams add_acute_columns
add_ae_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, cost = TRUE) %>%
    dplyr::mutate("{prefix}_attendances" := dplyr::if_else(eval(condition), cost_total_net, NA_real_))
}

#' Add PIS columns
#'
#' @inheritParams add_acute_columns
add_pis_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, cost = TRUE) %>%
    dplyr::mutate("{prefix}_paid_items" := dplyr::if_else(eval(condition), no_paid_items, NA_real_))
}

#' Add OoH columns
#'
#' @inheritParams add_acute_columns
add_ooh_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file <- episode_file %>%
    add_standard_cols(prefix, condition, cost = TRUE) %>%
    dplyr::mutate(
      "{prefix}_homeV" := dplyr::if_else(eval(condition) & smrtype == "OOH-HomeV", 1, NA_real_),
      "{prefix}_advice" := dplyr::if_else(eval(condition) & smrtype == "OOH-Advice", 1, NA_real_),
      "{prefix}_DN" := dplyr::if_else(eval(condition) & smrtype == "OOH-DN", 1, NA_real_),
      "{prefix}_NHS24" := dplyr::if_else(eval(condition) & smrtype == "OOH-NHS24", 1, NA_real_),
      "{prefix}_other" := dplyr::if_else(eval(condition) & smrtype == "OOH-Other", 1, NA_real_),
      "{prefix}_PCC" := dplyr::if_else(eval(condition) & smrtype == "OOH-PCC", 1, NA_real_),
      ooh_covid_advice = dplyr::if_else(eval(condition) & smrtype == "OOH-C19Adv", 1, NA_real_),
      ooh_covid_assessment = dplyr::if_else(eval(condition) & smrtype == "OOH-C19Ass", 1, NA_real_),
      ooh_covid_other = dplyr::if_else(eval(condition) & smrtype == "OOH-C190th", 1, NA_real_)
    )

  episode_file <- episode_file %>%
    dplyr::mutate(
      OoH_consultation_time = dplyr::if_else(eval(condition), as.numeric((lubridate::seconds_to_period(keytime2) + keydate2_dateformat) - (lubridate::seconds_to_period(keytime1) + keydate1_dateformat), units = "mins"), NA_real_),
      OoH_consultation_time = dplyr::if_else(OoH_consultation_time < 0, 0, OoH_consultation_time)
    )
  return(episode_file)
}

#' Add DN columns
#'
#' @inheritParams add_acute_columns
add_dn_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    dplyr::mutate("{prefix}_contacts" := dplyr::if_else(eval(condition), totalnodncontacts, NA_real_))
}

#' Add CMH columns
#'
#' @inheritParams add_acute_columns
add_cmh_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate("{prefix}_contacts" := dplyr::if_else(eval(condition), 1, NA_real_))
}

#' Add DD columns
#'
#' @inheritParams add_acute_columns
add_dd_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  condition_delay <- substitute(condition & primary_delay_reason != "9")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_NonCode9_episodes" := dplyr::if_else(eval(condition_delay), 1, NA_real_),
      "{prefix}_NonCode9_beddays" := dplyr::if_else(eval(condition_delay), yearstay, NA_real_)
    )
  condition_delay_9 <- substitute(condition & primary_delay_reason == "9")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_Code9_episodes" := dplyr::if_else(eval(condition_delay_9), 1, NA_real_),
      "{prefix}_Code9_beddays" := dplyr::if_else(eval(condition_delay_9), yearstay, NA_real_)
    )
  return(episode_file)
}

#' Add NSU columns
#'
#' @inheritParams add_acute_columns
add_nsu_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate("{prefix}" := dplyr::if_else(eval(condition), 1, NA_real_))
}

#' Add NRS columns
#'
#' @inheritParams add_acute_columns
add_nrs_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate("{prefix}" := dplyr::if_else(eval(condition), 1, NA_real_))
}

#' Add HL1 columns
#'
#' @inheritParams add_acute_columns
add_hl1_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, drop = "gpprac")
}

#' Add CH columns
#'
#' @inheritParams add_acute_columns
add_ch_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate(
      ch_cis_episodes = dplyr::if_else(eval(condition), first_ch_ep, NA_real_),
      ch_cost_per_day = dplyr::if_else(eval(condition) & yearstay > 0, cost_total_net / yearstay, NA_real_),
      ch_cost_per_day = dplyr::if_else(eval(condition) & yearstay == 0, cost_total_net / yearstay, ch_cost_per_day),
      ch_no_cost = eval(condition) & is.na(ch_cost_per_day),
      ch_ep_end = dplyr::if_else(eval(condition), keydate2_dateformat, lubridate::NA_Date_),
      ch_ep_end = dplyr::if_else(eval(condition) & is.na(ch_ep_end), lubridate::quarter(zoo::as.yearqtr(sc_latest_submission), type = "date_first"), ch_ep_end)
    )
}

#' Add HC columns
#'
#' @inheritParams add_acute_columns
add_hc_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file <- episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE) %>%
    dplyr::mutate(
      "{prefix}_total_hours" := dplyr::if_else(eval(condition), hc_hours_annual, NA_real_),
      "{prefix}_total_cost" := dplyr::if_else(eval(condition), cost_total_net, NA_real_),
    )
  condition_per <- substitute(condition & smrtype == "HC-Per")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_personal_episodes" := dplyr::if_else(eval(condition_per), 1, NA_real_),
      "{prefix}_personal_hours" := dplyr::if_else(eval(condition_per), HC_total_hours, NA_real_),
      "{prefix}_personal_hours_cost" := dplyr::if_else(eval(condition_per), cost_total_net, NA_real_)
    )
  condition_non_per <- substitute(condition & smrtype == "HC-Non-Per")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_non_personal_episodes" := dplyr::if_else(eval(condition_non_per), 1, NA_real_),
      "{prefix}_non_personal_hours" := dplyr::if_else(eval(condition_non_per), hc_hours_annual, NA_real_),
      "{prefix}_non_personal_hours_cost" := dplyr::if_else(eval(condition_non_per), cost_total_net, NA_real_)
    )
  condition_reabl <- substitute(condition & hc_reablement == 1)
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_reablement_episodes" := dplyr::if_else(eval(condition_reabl), 1, NA_real_),
      "{prefix}_reablement_hours" := dplyr::if_else(eval(condition_reabl), hc_hours_annual, NA_real_),
      "{prefix}_reablement_hours_cost" := dplyr::if_else(eval(condition_reabl), cost_total_net, NA_real_)
    )
}

#' Add AT columns
#'
#' @inheritParams add_acute_columns
add_at_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate(
      "{prefix}_alarms" := dplyr::if_else(eval(condition) & smrtype == "AT-Alarm", 1, NA_real_),
      "{prefix}_telecare" := dplyr::if_else(eval(condition) & smrtype == "AT-Tele", 1, NA_real_)
    )
}

#' Add SDS columns
#'
#' @inheritParams add_acute_columns
add_sds_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate(
      "{prefix}_option_1" := dplyr::if_else(eval(condition) & smrtype == "SDS-1", 1, NA_real_),
      "{prefix}_option_2" := dplyr::if_else(eval(condition) & smrtype == "SDS-2", 1, NA_real_),
      "{prefix}_option_3" := dplyr::if_else(eval(condition) & smrtype == "SDS-3", 1, NA_real_),
      "{prefix}_option_4" := dplyr::if_else(eval(condition) & smrtype == "SDS-4", 1, NA_real_)
    )
}

#' Add columns based on IPDC
#'
#' @description Add columns based on value in IPDC column, which can
#' be further split by Elective/Non-Elective CIJ.
#'
#' @inheritParams add_acute_columns
#' @param ipdc_d Whether to create columns based on IPDC = "D" (lgl)
#' @param elective Whether to create columns based on Elective/Non-Elective cij_pattype (lgl)
add_ipdc_cols <- function(episode_file, prefix, condition, ipdc_d = TRUE, elective = TRUE) {
  condition_i <- substitute(eval(condition) & ipdc == "I")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_inpatient_episodes" := dplyr::if_else(eval(condition_i), 1, NA_real_),
      "{prefix}_inpatient_beddays" := dplyr::if_else(eval(condition_i), yearstay, NA_real_)
    )
  if (elective) {
    condition_el <- substitute(condition_i & cij_pattype == "Elective")
    episode_file <- episode_file %>%
      dplyr::mutate(
        "{prefix}_el_inpatient_episodes" := dplyr::if_else(eval(condition_el), 1, NA_real_),
        "{prefix}_el_inpatient_beddays" := dplyr::if_else(eval(condition_el), yearstay, NA_real_),
        "{prefix}_el_inpatient_cost" := dplyr::if_else(eval(condition_el), cost_total_net, NA_real_)
      )
    condition_non_el <- substitute(condition_i & cij_pattype == "Non-Elective")
    episode_file <- episode_file %>%
      dplyr::mutate(
        "{prefix}_non_el_inpatient_episodes" := dplyr::if_else(eval(condition_non_el), 1, NA_real_),
        "{prefix}_non_el_inpatient_beddays" := dplyr::if_else(eval(condition_non_el), yearstay, NA_real_),
        "{prefix}_non_el_inpatient_cost" := dplyr::if_else(eval(condition_non_el), cost_total_net, NA_real_)
      )
  }
  if (ipdc_d) {
    condition_d <- substitute(eval(condition) & ipdc == "D")
    episode_file <- episode_file %>%
      dplyr::mutate(
        "{prefix}_daycase_episodes" := dplyr::if_else(eval(condition_d), 1, NA_real_),
        "{prefix}_daycase_cost" := dplyr::if_else(eval(condition_d), cost_total_net, NA_real_)
      )
  }
  return(episode_file)
}

#' Add standard columns
#'
#' @description Add standard columns (DoB, postcode, gpprac, episodes, cost) to episode file.
#'
#' @inheritParams add_acute_columns
#' @param drop Any columns out of "DoB", "postcode", and "gpprac" that should be dropped
#' @param episode Whether to create prefix_episodes col, e.g. "Acute_episodes"
#' @param cost Whether to create prefix_cost col, e.g. "Acute_cost"
add_standard_cols <- function(episode_file, prefix, condition, drop = NULL, episode = FALSE, cost = FALSE) {
  episode_file <- dplyr::bind_cols(episode_file, create_cols(episode_file, prefix, condition, drop))
  if (episode) {
    episode_file <- dplyr::mutate(episode_file, "{prefix}_episodes" := dplyr::if_else(eval(condition), 1, NA_real_))
  }
  if (cost) {
    episode_file <- dplyr::mutate(episode_file, "{prefix}_cost" := dplyr::if_else(eval(condition), cost_total_net, NA_real_))
  }
  return(episode_file)
}

#' Create standard cols
#'
#' @description Create standard cols (DoB, postcode, gpprac).
#'
#' @inheritParams add_acute_columns
#' @param drop Any columns out of "DoB", "postcode", and "gpprac" that should be dropped
create_cols <- function(episode_file, prefix, condition, drop) {
  cols <- c("DoB", "postcode", "gpprac")
  if (!is.null(drop)) {
    cols <- cols[cols != drop]
  }
  episode_file <- purrr::map_dfc(cols, ~ create_col(episode_file, .x, prefix, condition))
  return(episode_file)
}

#' Create standard col
#'
#' @description Create single standard column.
#'
#' @inheritParams add_acute_columns
#' @inheritParams na_type
create_col <- function(episode_file, col, prefix, condition) {
  episode_file %>%
    dplyr::mutate("{prefix}_{col}" := dplyr::if_else(eval(condition), .data[[tolower(col)]], na_type(col))) %>%
    dplyr::select(dplyr::last_col())
}

#' NA type
#'
#' @description Helper function to use correct NA type depending on
#' which type of column is created.
#'
#' @param col Which column to create ("DoB", "postcode", or "gpprac")
na_type <- function(col = c("DoB", "postcode", "gpprac")) {
  match.arg(col)
  na_type <- switch(col,
    "DoB" = lubridate::NA_Date_,
    "postcode" = NA_character_,
    "gpprac" = NA_real_
  )
  return(na_type)
}
