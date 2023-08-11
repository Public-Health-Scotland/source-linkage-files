#' Create individual file
#'
#' @description Creates individual file from episode file
#'
#' @param episode_file Tibble containing episodic data
#' @param anon_chi_in (Default:TRUE) Is `anon_chi` used in the input
#' (instead of chi)
#' @inheritParams run_episode_file
#'
#' @return The processed individual file
#' @family individual_file
#' @export
create_individual_file <- function(
    episode_file,
    year,
    write_to_disk = TRUE,
    anon_chi_in = TRUE,
    anon_chi_out = TRUE) {
  if (anon_chi_in) {
    episode_file <- slfhelper::get_chi(
      episode_file,
      anon_chi_var = "anon_chi",
      drop = TRUE
    ) %>%
      dplyr::mutate(chi = dplyr::na_if(.data$chi, ""))
  }

  individual_file <- episode_file %>%
    dplyr::select(dplyr::any_of(c(
      "year",
      "chi",
      "dob",
      "gender",
      "record_keydate1",
      "record_keydate2",
      "keytime1",
      "keytime2",
      "recid",
      "smrtype",
      "ipdc",
      "postcode",
      "gpprac",
      "cij_marker",
      "cij_start_date",
      "cij_end_date",
      "cij_pattype",
      "cij_pattype_code",
      "cij_ppa",
      "ch_chi_cis",
      "yearstay",
      "cost_total_net",
      "cost_total_net_inc_dnas",
      "attendance_status",
      "no_paid_items",
      "total_no_dn_contacts",
      "primary_delay_reason",
      "sc_latest_submission",
      "hc_hours_annual",
      "hc_reablement",
      "ooh_case_id"
    ))) %>%
    remove_blank_chi() %>%
    add_cij_columns() %>%
    add_all_columns() %>%
    aggregate_ch_episodes() %>%
    clean_up_ch(year) %>%
    recode_gender() %>%
    aggregate_by_chi() %>%
    clean_individual_file(year) %>%
    join_cohort_lookups(year) %>%
    match_on_ltcs(year) %>%
    join_deaths_data(year) %>%
    join_sparra_hhg(year) %>%
    join_slf_lookup_vars() %>%
    join_sc_client(year) %>%
    dplyr::mutate(year = year, .before = dplyr::everything())

  if (anon_chi_out) {
    individual_file <- individual_file %>%
      tidyr::replace_na(list(chi = "")) %>%
      slfhelper::get_anon_chi() %>%
      dplyr::mutate(anon_chi = dplyr::na_if(.data$anon_chi, ""))
  }

  if (write_to_disk) {
    slf_indiv_path <- get_file_path(
      get_year_dir(year),
      stringr::str_glue(
        "source-individual-file-{year}.parquet"
      ),
      check_mode = "write"
    )

    write_file(individual_file, slf_indiv_path)
  }

  return(individual_file)
}

#' Remove blank CHI
#'
#' @description Convert blank strings to NA and remove NAs from CHI column
#' @family individual_file
#' @inheritParams create_individual_file
remove_blank_chi <- function(episode_file) {
  cli::cli_alert_info("Remove blank CHI function started at {Sys.time()}")

  episode_file %>%
    dplyr::mutate(chi = dplyr::na_if(.data$chi, "")) %>%
    dplyr::filter(!is.na(.data$chi))
}


#' Add CIJ-related columns
#'
#' @description Add new columns related to CIJ
#' @family individual_file
#' @inheritParams create_individual_file
add_cij_columns <- function(episode_file) {
  cli::cli_alert_info("Add cij columns function started at {Sys.time()}")

  episode_file %>%
    dplyr::mutate(
      cij_non_el = dplyr::if_else(
        .data$cij_pattype_code == 0L,
        .data$cij_marker,
        NA_real_
      ),
      cij_el = dplyr::if_else(
        .data$cij_pattype_code == 1L,
        .data$cij_marker,
        NA_real_
      ),
      cij_mat = dplyr::if_else(
        .data$cij_pattype_code == 2L,
        .data$cij_marker,
        NA_real_
      ),
      cij_delay = dplyr::if_else(
        .data$recid == "DD",
        .data$cij_marker,
        NA_real_
      ),
      preventable_admissions = dplyr::if_else(
        .data$cij_ppa == 1L,
        .data$cij_marker,
        NA_integer_
      )
    )
}

#' Add all columns
#'
#' @description Add new columns based on SMRType and recid which follow a pattern
#' of prefixed column names created based on some condition.
#' @family individual_file
#' @inheritParams create_individual_file
add_all_columns <- function(episode_file) {
  cli::cli_alert_info("Add all columns function started at {Sys.time()}")

  episode_file %>%
    add_acute_columns("Acute", (.data$smrtype == "Acute-DC" | .data$smrtype == "Acute-IP") & .data$cij_pattype != "Maternity") %>%
    add_mat_columns("Mat", .data$recid == "02B" | .data$cij_pattype == "Maternity") %>%
    add_mh_columns("MH", .data$recid == "04B" & .data$cij_pattype != "Maternity") %>%
    add_gls_columns("GLS", .data$smrtype == "GLS-IP") %>%
    add_op_columns("OP", .data$recid == "00B") %>%
    add_ae_columns("AE", .data$recid == "AE2") %>%
    add_pis_columns("PIS", .data$recid == "PIS") %>%
    add_ooh_columns("OoH", .data$recid == "OoH") %>%
    add_dn_columns("DN", .data$recid == "DN") %>%
    add_cmh_columns("CMH", .data$recid == "CMH") %>%
    add_dd_columns("DD", .data$recid == "DD") %>%
    add_nsu_columns("NSU", .data$recid == "NSU") %>%
    add_nrs_columns("NRS", .data$recid == "NRS") %>%
    add_hl1_columns("HL1", .data$recid == "HL1") %>%
    add_ch_columns("CH", .data$recid == "CH") %>%
    add_hc_columns("HC", .data$recid == "HC") %>%
    add_at_columns("AT", .data$recid == "AT") %>%
    add_sds_columns("SDS", .data$recid == "SDS") %>%
    dplyr::mutate(
      health_net_cost = rowSums(
        dplyr::pick(
          .data$Acute_cost,
          .data$Mat_cost,
          .data$MH_cost,
          .data$GLS_cost,
          .data$OP_cost_attend,
          .data$AE_cost,
          .data$PIS_cost,
          .data$OoH_cost
        ),
        na.rm = TRUE
      ),
      health_net_cost_inc_dnas = .data$health_net_cost + dplyr::if_else(
        is.na(.data$OP_cost_dnas),
        0.0,
        .data$OP_cost_dnas
      )
    )
}

#' Add Acute columns
#'
#' @inheritParams create_individual_file
#' @param prefix Prefix to add to related columns, e.g. "Acute"
#' @param condition Condition to create new columns based on
#' @family individual_file
add_acute_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition)
}

#' Add Mat columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_mat_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition, elective = FALSE)
}

#' Add MH columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_mh_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition, ipdc_d = FALSE)
}

#' Add GLS columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_gls_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
    add_ipdc_cols(prefix, condition, ipdc_d = FALSE)
}

#' Add OP columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_op_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file <- episode_file %>%
    add_standard_cols(prefix, condition)
  condition_1 <- substitute(condition & attendance_status == 1L)
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_newcons_attendances" := dplyr::if_else(eval(condition_1), 1L, NA_integer_),
      "{prefix}_cost_attend" := dplyr::if_else(eval(condition_1), .data$cost_total_net, NA_real_)
    )
  condition_5_8 <- substitute(condition & attendance_status %in% c(5L, 8L))
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_newcons_dnas" := dplyr::if_else(eval(condition_5_8), 1L, NA_integer_),
      "{prefix}_cost_dnas" := dplyr::if_else(eval(condition_5_8), .data$cost_total_net_inc_dnas, NA_real_)
    )
  return(episode_file)
}

#' Add AE columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_ae_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, cost = TRUE) %>%
    dplyr::mutate("{prefix}_attendances" := dplyr::if_else(eval(condition), 1L, NA_integer_))
}

#' Add PIS columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_pis_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition, cost = TRUE) %>%
    dplyr::mutate("{prefix}_paid_items" := dplyr::if_else(eval(condition), .data$no_paid_items, NA_integer_))
}

#' Add OoH columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_ooh_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file <- episode_file %>%
    add_standard_cols(prefix, condition, cost = TRUE) %>%
    dplyr::mutate(
      "{prefix}_homeV" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-HomeV", 1L, NA_integer_),
      "{prefix}_advice" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-Advice", 1L, NA_integer_),
      "{prefix}_DN" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-DN", 1L, NA_integer_),
      "{prefix}_NHS24" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-NHS24", 1L, NA_integer_),
      "{prefix}_other" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-Other", 1L, NA_integer_),
      "{prefix}_PCC" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-PCC", 1L, NA_integer_),
      "{prefix}_covid_advice" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-C19Adv", 1L, NA_integer_),
      "{prefix}_covid_assessment" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-C19Ass", 1L, NA_integer_),
      "{prefix}_covid_other" := dplyr::if_else(eval(condition) & .data$smrtype == "OOH-C190th", 1L, NA_integer_)
    )

  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_consultation_time" := dplyr::if_else(
        eval(condition),
        pmax(
          0.0,
          as.numeric((lubridate::seconds_to_period(.data$keytime2) + .data$record_keydate2) - (lubridate::seconds_to_period(.data$keytime1) + .data$record_keydate1), units = "mins")
        ),
        NA_real_
      )
    )

  return(episode_file)
}

#' Add DN columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_dn_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  if ("total_no_dn_contacts" %in% names(episode_file)) {
    episode_file %>%
      add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
      dplyr::mutate(
        "{prefix}_contacts" := dplyr::if_else(
          eval(condition),
          .data$total_no_dn_contacts,
          NA_integer_
        )
      )
  } else {
    episode_file %>%
      add_standard_cols(prefix, condition, episode = TRUE, cost = TRUE) %>%
      dplyr::mutate("{prefix}_contacts" := NA_integer_)
  }
}

#' Add CMH columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_cmh_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate("{prefix}_contacts" := dplyr::if_else(eval(condition), 1L, NA_integer_))
}

#' Add DD columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_dd_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  condition_delay <- substitute(condition & primary_delay_reason != "9")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_NonCode9_episodes" := dplyr::if_else(eval(condition_delay), 1L, NA_integer_),
      "{prefix}_NonCode9_beddays" := dplyr::if_else(eval(condition_delay), .data$yearstay, NA_real_)
    )
  condition_delay_9 <- substitute(condition & primary_delay_reason == "9")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_Code9_episodes" := dplyr::if_else(eval(condition_delay_9), 1L, NA_integer_),
      "{prefix}_Code9_beddays" := dplyr::if_else(eval(condition_delay_9), .data$yearstay, NA_real_)
    )
  return(episode_file)
}

#' Add NSU columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_nsu_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate("{prefix}" := dplyr::if_else(eval(condition), 1L, NA_integer_))
}

#' Add NRS columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_nrs_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate("{prefix}" := dplyr::if_else(eval(condition), 1L, NA_integer_))
}

#' Add HL1 columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_hl1_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition)
}

#' Add CH columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_ch_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate(
      ch_cost_per_day = dplyr::if_else(
        eval(condition) & .data$yearstay > 0.0,
        .data$cost_total_net / .data$yearstay,
        .data$cost_total_net
      ),
      ch_no_cost = eval(condition) & is.na(.data$ch_cost_per_day),
      ch_ep_end = dplyr::if_else(
        eval(condition),
        .data$record_keydate2,
        lubridate::NA_Date_
      ),
      # If end date is missing use the first day of next FY quarter
      ch_ep_end = dplyr::if_else(
        eval(condition) & is.na(.data$ch_ep_end),
        start_next_fy_quarter(.data$sc_latest_submission),
        .data$ch_ep_end
      )
    )
}

#' Add HC columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_hc_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file <- episode_file %>%
    add_standard_cols(prefix, condition, episode = TRUE) %>%
    dplyr::mutate(
      "{prefix}_total_hours" := dplyr::if_else(
        eval(condition),
        .data$hc_hours_annual,
        NA_real_
      ),
      "{prefix}_total_cost" := dplyr::if_else(
        eval(condition),
        .data$cost_total_net,
        NA_real_
      )
    )
  condition_per <- substitute(condition & smrtype == "HC-Per")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_personal_episodes" := dplyr::if_else(eval(condition_per), 1L, NA_integer_),
      "{prefix}_personal_hours" := dplyr::if_else(eval(condition_per), .data$HC_total_hours, NA_real_),
      "{prefix}_personal_hours_cost" := dplyr::if_else(eval(condition_per), .data$cost_total_net, NA_real_)
    )
  condition_non_per <- substitute(condition & smrtype == "HC-Non-Per")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_non_personal_episodes" := dplyr::if_else(eval(condition_non_per), 1L, NA_integer_),
      "{prefix}_non_personal_hours" := dplyr::if_else(eval(condition_non_per), .data$hc_hours_annual, NA_real_),
      "{prefix}_non_personal_hours_cost" := dplyr::if_else(eval(condition_non_per), .data$cost_total_net, NA_real_)
    )
  condition_reabl <- substitute(condition & hc_reablement == 1L)
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_reablement_episodes" := dplyr::if_else(eval(condition_reabl), 1L, NA_integer_),
      "{prefix}_reablement_hours" := dplyr::if_else(eval(condition_reabl), .data$hc_hours_annual, NA_real_),
      "{prefix}_reablement_hours_cost" := dplyr::if_else(eval(condition_reabl), .data$cost_total_net, NA_real_)
    )
}

#' Add AT columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_at_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate(
      "{prefix}_alarms" := dplyr::if_else(eval(condition) & .data$smrtype == "AT-Alarm", 1L, NA_integer_),
      "{prefix}_telecare" := dplyr::if_else(eval(condition) & .data$smrtype == "AT-Tele", 1L, NA_integer_)
    )
}

#' Add SDS columns
#'
#' @inheritParams add_acute_columns
#' @family individual_file
add_sds_columns <- function(episode_file, prefix, condition) {
  condition <- substitute(condition)
  episode_file %>%
    add_standard_cols(prefix, condition) %>%
    dplyr::mutate(
      "{prefix}_option_1" := dplyr::if_else(eval(condition) & .data$smrtype == "SDS-1", 1L, NA_integer_),
      "{prefix}_option_2" := dplyr::if_else(eval(condition) & .data$smrtype == "SDS-2", 1L, NA_integer_),
      "{prefix}_option_3" := dplyr::if_else(eval(condition) & .data$smrtype == "SDS-3", 1L, NA_integer_),
      "{prefix}_option_4" := dplyr::if_else(eval(condition) & .data$smrtype == "SDS-4", 1L, NA_integer_)
    )
}

#' Add columns based on IPDC
#'
#' @description Add columns based on value in IPDC column, which can
#' be further split by Elective/Non-Elective CIJ.
#'
#' @inheritParams add_acute_columns
#' @param ipdc_d Whether to create columns based on IPDC = "D" (lgl)
#' @param elective Whether to create columns based on Elective/Non-Elective
#' cij_pattype (lgl)
#' @family individual_file
add_ipdc_cols <- function(episode_file, prefix, condition, ipdc_d = TRUE, elective = TRUE) {
  condition_i <- substitute(eval(condition) & ipdc == "I")
  episode_file <- episode_file %>%
    dplyr::mutate(
      "{prefix}_inpatient_cost" := dplyr::if_else(eval(condition_i), .data$cost_total_net, NA_real_),
      "{prefix}_inpatient_episodes" := dplyr::if_else(eval(condition_i), 1L, NA_integer_),
      "{prefix}_inpatient_beddays" := dplyr::if_else(eval(condition_i), .data$yearstay, NA_real_)
    )
  if (elective) {
    condition_el <- substitute(condition_i & cij_pattype == "Elective")
    episode_file <- episode_file %>%
      dplyr::mutate(
        "{prefix}_el_inpatient_episodes" := dplyr::if_else(eval(condition_el), 1L, NA_integer_),
        "{prefix}_el_inpatient_beddays" := dplyr::if_else(eval(condition_el), .data$yearstay, NA_real_),
        "{prefix}_el_inpatient_cost" := dplyr::if_else(eval(condition_el), .data$cost_total_net, NA_real_)
      )
    condition_non_el <- substitute(condition_i & cij_pattype == "Non-Elective")
    episode_file <- episode_file %>%
      dplyr::mutate(
        "{prefix}_non_el_inpatient_episodes" := dplyr::if_else(eval(condition_non_el), 1L, NA_integer_),
        "{prefix}_non_el_inpatient_beddays" := dplyr::if_else(eval(condition_non_el), .data$yearstay, NA_real_),
        "{prefix}_non_el_inpatient_cost" := dplyr::if_else(eval(condition_non_el), .data$cost_total_net, NA_real_)
      )
  }
  if (ipdc_d) {
    condition_d <- substitute(eval(condition) & ipdc == "D")
    episode_file <- episode_file %>%
      dplyr::mutate(
        "{prefix}_daycase_episodes" := dplyr::if_else(eval(condition_d), 1L, NA_integer_),
        "{prefix}_daycase_cost" := dplyr::if_else(eval(condition_d), .data$cost_total_net, NA_real_)
      )
  }
  return(episode_file)
}

#' Add standard columns
#'
#' @description Add standard columns (DoB, postcode, gpprac, episodes, cost)
#' to episode file.
#'
#' @inheritParams add_acute_columns
#' @param episode Whether to create prefix_episodes col, e.g. "Acute_episodes"
#' @param cost Whether to create prefix_cost col, e.g. "Acute_cost"
#' @family individual_file
add_standard_cols <- function(episode_file, prefix, condition, episode = FALSE, cost = FALSE) {
  if (episode) {
    episode_file <- dplyr::mutate(episode_file, "{prefix}_episodes" := dplyr::if_else(eval(condition), 1L, NA_integer_))
  }
  if (cost) {
    episode_file <- dplyr::mutate(episode_file, "{prefix}_cost" := dplyr::if_else(eval(condition), .data$cost_total_net, NA_real_))
  }
  return(episode_file)
}

#' Clean up CH
#'
#' @description Clean up CH-related columns.
#'
#' @inheritParams create_individual_file
#' @family individual_file
clean_up_ch <- function(episode_file, year) {
  cli::cli_alert_info("Clean up CH function started at {Sys.time()}")

  episode_file %>%
    dplyr::mutate(
      fy_end = end_fy(year),
      fy_start = start_fy(year)
    ) %>%
    dplyr::mutate(
      term_1 = pmin(.data$ch_ep_end, .data$fy_end + 1L),
      term_2 = pmax(.data$ch_ep_start, .data$fy_start)
    ) %>%
    dplyr::mutate(
      ch_beddays = dplyr::if_else(
        .data$recid == "CH",
        as.numeric(.data$term_1 - .data$term_2),
        NA_real_
      ),
      ch_cost = dplyr::if_else(
        .data$recid == "CH" & .data$ch_no_cost == 0L,
        .data$ch_beddays * .data$ch_cost_per_day,
        NA_real_
      ),
      ch_beddays = dplyr::if_else(
        .data$recid == "CH" & .data$ch_chi_cis == 0L,
        0L,
        .data$ch_beddays
      ),
      ch_cost = dplyr::if_else(
        .data$recid == "CH" & .data$ch_chi_cis == 0L,
        0.0,
        .data$ch_cost
      )
    ) %>%
    dplyr::select(-c("fy_end", "fy_start", "term_1", "term_2"))
}

#' Recode gender
#'
#' @description Recode gender to 1.5 if 0 or 9.
#'
#' @inheritParams create_individual_file
#' @family individual_file
recode_gender <- function(episode_file) {
  cli::cli_alert_info("Recode Gender function started at {Sys.time()}")

  episode_file %>%
    dplyr::mutate(
      gender = dplyr::if_else(
        .data$gender %in% c(0L, 9L),
        1.5,
        .data$gender
      )
    )
}

#' Condition columns
#'
#' @description Returns chr vector of column names
#' which follow format "condition" and "condition_date" e.g.
#' "dementia" and "dementia_date"
#' @family individual_file
condition_cols <- function() {
  conditions <- slfhelper::ltc_vars
  date_cols <- paste0(conditions, "_date")
  all_cols <- c(conditions, date_cols)
  return(all_cols)
}

#' Custom maximum
#'
#' @description Custom maximum function which removes
#' missing values but doesn't return Inf if all values
#' are missing (instead returns NA)
#'
#' @param x Vector to return max of
#' @family helper_funs
max_no_inf <- function(x) {
  dplyr::if_else(all(is.na(x)), NA, max(x, na.rm = TRUE))
}

#' Custom minimum
#'
#' @description Custom minimum function which removes
#' missing values but doesn't return Inf if all values
#' are missing (instead returns NA)
#'
#' @param x Vector to return min of
#' @family helper_funs
min_no_inf <- function(x) {
  dplyr::if_else(all(is.na(x)), NA, min(x, na.rm = TRUE))
}

#' Clean individual file
#'
#' @description Clean up columns in individual file
#'
#' @param individual_file Individual file where each row represents a unique CHI
#' @param year Financial year e.g 1718
clean_individual_file <- function(individual_file, year) {
  cli::cli_alert_info("Clean individual file function started at {Sys.time()}")

  individual_file %>%
    dplyr::select(!dplyr::any_of(c(
      "ch_no_cost",
      "no_paid_items",
      "total_no_dn_contacts",
      "cost_total_net_inc_dnas"
    ))) %>%
    clean_up_gender() %>%
    dplyr::mutate(age = compute_mid_year_age(year, .data$dob))
}

#' Clean up gender column
#'
#' @description Clean up column containing gender.
#'
#' @inheritParams clean_individual_file
clean_up_gender <- function(individual_file) {
  individual_file %>%
    dplyr::mutate(
      gender = dplyr::case_when(
        .data$gender != 1.5 ~ round(.data$gender),
        .default = phsmethods::sex_from_chi(.data$chi, chi_check = FALSE)
      )
    )
}

#' Join slf lookup variables
#'
#' @description Join lookup variables from slf postcode lookup and slf gpprac
#'              lookup.
#'
#' @param individual_file the processed individual file.
#' @param slf_postcode_lookup SLF processed postcode lookup
#' @param slf_gpprac_lookup SLF processed gpprac lookup
#' @param hbrescode_var hbrescode variable
#'
join_slf_lookup_vars <- function(individual_file,
                                 slf_postcode_lookup = read_file(get_slf_postcode_path()),
                                 slf_gpprac_lookup = read_file(
                                   get_slf_gpprac_path(),
                                   col_select = c("gpprac", "cluster", "hbpraccode")
                                 ),
                                 hbrescode_var = "hb2018") {
  individual_file <- individual_file %>%
    dplyr::left_join(
      slf_postcode_lookup,
      by = "postcode"
    ) %>%
    dplyr::left_join(
      slf_gpprac_lookup,
      by = "gpprac"
    ) %>%
    dplyr::rename(hbrescode = hbrescode_var)

  return(individual_file)
}
# TODO Remove the client data from the individual Social Care extracts
# and instead, use this function in the episode file to match on the client
# data to all episodes.
#' Join sc client variables onto individual file
#'
#' @description Match on sc client variables.
#'
#' @param individual_file the processed individual file
#' @param year financial year.
#' @param sc_client SC client lookup
#' @param sc_demographics SC Demographic lookup
join_sc_client <- function(
    individual_file,
    year,
    sc_client = read_file(get_source_extract_path(year, "Client")),
    sc_demographics = read_file(get_sc_demog_lookup_path(),
      col_select = c("sending_location", "social_care_id", "chi")
    )) {
  # TODO Update the client lookup processing script to match
  # on demographics there so the client lookup already has CHI.

  # Match to demographics lookup to get CHI
  join_client_demog <- sc_client %>%
    dplyr::left_join(
      sc_demographics %>%
        dplyr::select("sending_location", "social_care_id", "chi"),
      by = c("sending_location", "social_care_id")
    )

  # Match on client variables by chi
  individual_file <- individual_file %>%
    dplyr::left_join(
      join_client_demog,
      by = "chi"
    ) %>%
    dplyr::select(!c("sending_location", "social_care_id", "sc_latest_submission"))

  return(individual_file)
}
