#' Process the all Care Home extract
#'
#' @description This will read and process the
#' all Care Home extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process
#' @param sc_demog_lookup The Social Care Demographics lookup produced by
#' [process_lookup_sc_demographics()].
#' @param it_chi_deaths_data The processed lookup of deaths from IT produced
#' with [process_it_chi_deaths()].
#' @param ch_name_lookup_path Path to the Care Home name Lookup Excel workbook.
#' @param spd_path (Optional) Path the Scottish Postcode Directory, default is
#' to use [get_spd_path()].
#' @param write_to_disk (Optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
#' @export


process_sc_all_care_home <- function(
    data,
    sc_demog_lookup = read_file(get_sc_demog_lookup_path()) %>% slfhelper::get_chi(),
    it_chi_deaths_data = read_file(get_slf_chi_deaths_path()) %>% slfhelper::get_chi(),
    ch_name_lookup_path = get_slf_ch_name_lookup_path(),
    spd_path = get_spd_path(),
    write_to_disk = TRUE) {
  ## Data Cleaning-----------------------------------------------------

  # to do:
  # compare old to new
  # PR

  ch_clean <- data %>%
    dplyr::mutate(
      # Set missing admission date to start of the submitted quarter (n = 2)
      ch_admission_date = dplyr::if_else(
        is.na(.data[["ch_admission_date"]]),
        .data[["period_start_date"]],
        .data[["ch_admission_date"]]
      ),
      # If the dis date is before admission, remove the dis date (n = 5)
      ch_discharge_date = dplyr::if_else(
        .data[["ch_admission_date"]] > .data[["ch_discharge_date"]],
        lubridate::NA_Date_,
        .data[["ch_discharge_date"]]
      )
    ) %>%
    dplyr::full_join(sc_demog_lookup, # this is the correct join.
      by = c("sending_location", "social_care_id")
    ) %>%
    replace_sc_id_with_latest() %>%
    dplyr::select(-latest_flag, -latest_sc_id)


  # cleaning and matching care home names
  name_postcode_clean <- fill_ch_names(
    ch_data = ch_clean,
    ch_name_lookup_path = ch_name_lookup_path,
    spd_path = spd_path
  )

  fixed_ch_provider <- name_postcode_clean %>%
    dplyr::select(-ch_name_validated, -open_interval, -latest_close_date, -ch_name_old, -ch_postcode_old) %>%
    dplyr::mutate(
      ch_provider = dplyr::if_else(is.na(.data[["ch_provider"]]), 6L, .data[["ch_provider"]]) # (n = 2)
    ) %>%
    # sort data
    dplyr::arrange(
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["period"]],
      .data[["ch_admission_date"]]
    ) %>%
    dplyr::group_by(
      .data[["sending_location"]],
      .data[["social_care_id"]]
    ) %>%
    # work out the min and max ch provider in an episode
    dplyr::mutate(
      min_ch_provider = min(.data[["ch_provider"]]),
      max_ch_provider = max(.data[["ch_provider"]]),
      # if care home provider is different across cases, set to "6".
      # tidy up ch_provider using 6 when disagreeing values
      ch_provider = dplyr::if_else(
        .data[["min_ch_provider"]] != .data[["max_ch_provider"]],
        6L,
        .data[["ch_provider"]]
      )
    ) %>%
    dplyr::select(
      -"min_ch_provider",
      -"max_ch_provider"
    ) %>%
    dplyr::ungroup()


  fixed_nursing_provision <- fixed_ch_provider %>%
    dplyr::group_by(
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["ch_admission_date"]]
    ) %>%
    # fill in nursing care provision when missing
    # but present in the following entry (n = 0)
    dplyr::mutate(
      nursing_care_provision = dplyr::na_if(.data[["nursing_care_provision"]], 9L)
    ) %>%
    tidyr::fill(.data[["nursing_care_provision"]], .direction = "downup")


  ready_to_merge <- fixed_nursing_provision %>%
    # remove any duplicate records before merging
    dplyr::distinct() %>% # (n = 3)
    # sort data
    dplyr::arrange(
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["ch_admission_date"]],
      .data[["period"]]
    ) %>%
    dplyr::group_by(
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["ch_admission_date"]]
    ) %>%
    # counter for split episodes
    # a split episode is an episode where the admission date is the same but the nursing provider has changed.
    # We want to keep the nursing provision changes when we merge cases that have the same admission date
    dplyr::mutate(previous_nursing_care_provision = dplyr::lag(.data[["nursing_care_provision"]])) %>%
    # create a T/F flag for if nursing provision was the same as previous record with same admission date
    dplyr::mutate(split_episode = tidyr::replace_na(.data[["previous_nursing_care_provision"]] != nursing_care_provision, TRUE)) %>%
    dplyr::group_by(
      .data[["social_care_id"]],
      .data[["sending_location"]],
      .data[["split_episode"]]
    ) %>%
    # create a count of each time the nursing provision changes between records with the same admission date
    dplyr::mutate(split_episode_counter = ifelse(split_episode == TRUE, dplyr::row_number(), NA)) %>%
    dplyr::group_by(
      .data[["social_care_id"]],
      .data[["sending_location"]]
    ) %>%
    # fill split episode counter. This will create a new id number for each different nursing provision within an episode
    tidyr::fill(split_episode_counter, .direction = c("down")) %>%
    dplyr::select(-previous_nursing_care_provision, -split_episode)


  # Merge records to a single row per episode where admission is the same
  ch_episode <- ready_to_merge %>%
    dplyr::group_by(
      .data[["chi"]],
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["ch_admission_date"]],
      .data[["nursing_care_provision"]],
      .data[["split_episode_counter"]]
    ) %>%
    dplyr::arrange(
      dplyr::desc(.data[["period"]]),
      dplyr::desc(.data[["ch_discharge_date"]]),
      dplyr::desc(.data[["ch_provider"]]),
      dplyr::desc(.data[["period_end_date"]]),
      dplyr::desc(.data[["period_start_date"]]),
      dplyr::desc(.data[["ch_name"]]),
      dplyr::desc(.data[["ch_postcode"]]),
      dplyr::desc(.data[["reason_for_admission"]]),
      dplyr::desc(.data[["type_of_admission"]]),
      .data[["gender"]],
      .data[["dob"]],
      .data[["postcode"]]
    ) %>%
    dplyr::summarise(
      sc_latest_submission = dplyr::first(.data[["period"]]),
      dplyr::across(c(
        "ch_discharge_date",
        "ch_provider",
        "period_end_date",
        "period_start_date",
        "ch_name",
        "ch_postcode",
        "reason_for_admission",
        "type_of_admission"
      ), dplyr::first),
      dplyr::across(c("gender", "dob", "postcode"), dplyr::first)
    ) %>%
    # If the admission date is missing use the period start date
    # otherwise use the start of the quarter
    dplyr::mutate(
      ch_admission_date = dplyr::if_else(is.na(.data[["ch_admission_date"]]),
        .data[["period_start_date"]],
        .data[["ch_admission_date"]]
      ),
      # If it's the last episode(s) then keep the discharge date(s), otherwise
      # use the end of the quarter
      ch_discharge_date = dplyr::if_else(is.na(.data[["ch_discharge_date"]]),
        .data[["period_end_date"]],
        .data[["ch_discharge_date"]]
      )
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-period_start_date, -split_episode_counter)


  # Compare to Deaths Data
  # match ch_episode data with deaths data
  # TO DO should this be boxi nrs death dates instead of IT extract deaths?
  matched_deaths_data <- ch_episode %>%
    dplyr::left_join(it_chi_deaths_data,
      by = "chi"
    ) %>%
    # compare discharge date with NRS and CHI death date
    # if either of the dates are 5 or fewer days before discharge
    # adjust the discharge date to the date of death
    # corrects most cases of ‘discharge after death’
    dplyr::mutate(
      dis_after_death = tidyr::replace_na(
        .data[["death_date"]] > (.data[["ch_discharge_date"]] - lubridate::days(5L)) &
          .data[["death_date"]] < .data[["ch_discharge_date"]],
        FALSE
      ),
      ch_discharge_date = dplyr::if_else(.data[["dis_after_death"]],
        .data[["death_date"]],
        .data[["ch_discharge_date"]]
      )
    ) %>%
    dplyr::ungroup() %>%
    # remove any episodes where discharge is now before admission,
    # i.e. death was before admission
    dplyr::filter( # (n = 67)
      !tidyr::replace_na(
        .data[["ch_discharge_date"]] < .data[["ch_admission_date"]],
        FALSE
      )
    )

  # Continuous Care Home Stays
  # Stay will be continuous as long as the admission date is the next day or
  # earlier than the previous discharge date.
  # creates a CIS  flag for CHI across all of scotland
  # and a CIS for social care ID and sending location for just that LA
  ch_chi_markers <- matched_deaths_data %>%
    # uses the chi to flag continuous stays. Will flag cases even if in another LA
    dplyr::group_by(.data[["chi"]]) %>%
    # create variable for previous discharge date + 1 day
    dplyr::mutate(previous_discharge_date_chi = dplyr::lag(.data[["ch_discharge_date"]]) + lubridate::days(1L)) %>%
    # TRUE/FALSE flag for if admission date is before or equal to previous discharge date + 1 day
    dplyr::mutate(continuous_stay_flag_chi = tidyr::replace_na(.data[["ch_admission_date"]] <= previous_discharge_date_chi, FALSE)) %>%
    # different to code in above sections.
    # we want to uniquely identify all cases where the flag is FALSE. and only the first case where the flag is TRUE
    # to do this create a variable of the flag in the previous row
    dplyr::mutate(previous_continuous_stay_flag_chi = tidyr::replace_na(dplyr::lag(.data[["continuous_stay_flag_chi"]]), FALSE)) %>%
    dplyr::mutate(continuous_stay_chi = ifelse(continuous_stay_flag_chi == FALSE |
      (continuous_stay_flag_chi == TRUE & previous_continuous_stay_flag_chi == FALSE), FALSE, TRUE)) %>%
    dplyr::group_by(
      .data[["chi"]],
      .data[["continuous_stay_chi"]]
    ) %>%
    # gives cases their unique CIS identifier
    dplyr::mutate(ch_chi_cis = ifelse(continuous_stay_chi == FALSE, dplyr::row_number(), NA)) %>%
    dplyr::group_by(
      .data[["social_care_id"]],
      .data[["sending_location"]]
    ) %>%
    # fills in CIS identifier for all cases
    tidyr::fill(ch_chi_cis, .direction = c("down")) %>%
    # This is the same but uses the social care id and sending location so can be used for
    # episodes that are not attached to a CHI number
    # This will restrict continuous stays to each Local Authority
    sc_ch_id_markers() <- chi_chi_markers %>%
    dplyr::group_by(.data[["social_care_id"]], .data[["sending_location"]]) %>%
    # create variable for previous discharge date + 1 day
    dplyr::mutate(previous_discharge_date_sc = dplyr::lag(.data[["ch_discharge_date"]]) + lubridate::days(1L)) %>%
    # TRUE/FALSE flag for if admission date is before or equal to previous discharge date + 1 day
    dplyr::mutate(continuous_stay_flag_sc = tidyr::replace_na(.data[["ch_admission_date"]] <= previous_discharge_date_sc, FALSE)) %>%
    # we want to uniquely identify all cases where the flag is FALSE. and only the first case where the flag is TRUE
    # to do this create a variable of the flag in the previous row
    dplyr::mutate(previous_continuous_stay_flag_sc = tidyr::replace_na(dplyr::lag(.data[["continuous_stay_flag_sc"]]), FALSE)) %>%
    dplyr::mutate(continuous_stay_sc = ifelse(continuous_stay_flag_sc == FALSE |
      (continuous_stay_flag_sc == TRUE & previous_continuous_stay_flag_sc == FALSE), FALSE, TRUE)) %>%
    dplyr::group_by(.data[["social_care_id"]], .data[["sending_location"]], .data[["continuous_stay_sc"]]) %>%
    # gives cases their unique CIS identifier
    dplyr::mutate(ch_sc_id_cis = ifelse(continuous_stay_sc == FALSE, dplyr::row_number(), NA)) %>%
    dplyr::group_by(.data[["social_care_id"]], .data[["sending_location"]]) %>%
    # fills in CIS identifier for all cases
    tidyr::fill(ch_sc_id_cis, .direction = c("down")) %>%
    dplyr::select(
      -previous_discharge_date_chi, -continuous_stay_flag_chi, -previous_continuous_stay_flag_chi, -continuous_stay_chi,
      -previous_discharge_date_sc, -continuous_stay_flag_sc, -previous_continuous_stay_flag_sc, -continuous_stay_sc,
      -dis_after_death, -death_date_nrs, -death_date_chi
    )


  # Do a recode on the old reason for admission for respite stays.
  adm_reason_recoded <- sc_ch_id_markers %>%
    dplyr::group_by(
      .data[["social_care_id"]],
      .data[["sending_location"]],
      .data[["ch_sc_id_cis"]]
    ) %>%
    dplyr::mutate(
      ch_ep_start = min(.data[["ch_admission_date"]]),
      # Creates a vector for the earliest date out of the end of period and discharge date.
      # And will then select what ever is the latest date out of those
      ch_ep_end = max(
        pmin(
          .data[["period_end_date"]],
          .data[["ch_discharge_date"]],
          na.rm = TRUE
        )
      )
    ) %>%
    dplyr::ungroup() %>%
    # Flag respite stays.
    dplyr::mutate(
      stay_los = lubridate::time_length(lubridate::interval(.data[["ch_ep_start"]], .data[["ch_ep_end"]]), "weeks"),
      stay_respite = .data[["stay_los"]] < 6.0,
      type_of_admission = dplyr::if_else(is.na(.data[["type_of_admission"]]),
        dplyr::case_when(.data[["reason_for_admission"]] == 1L ~ 1L,
          .data[["reason_for_admission"]] == 2L ~ 2L,
          stay_respite ~ 1L, # (n = 40573)
          .default = 3L
        ),
        .data[["type_of_admission"]]
      )
    ) %>%
    dplyr::select(-ch_ep_start, -ch_ep_end, -stay_los, -stay_respite)



  ch_data_final <- adm_reason_recoded %>%
    create_person_id() %>%
    dplyr::rename(
      record_keydate1 = "ch_admission_date",
      record_keydate2 = "ch_discharge_date",
      ch_adm_reason = "type_of_admission",
      ch_nursing = "nursing_care_provision"
    ) %>%
    # recode the care home provider description
    dplyr::mutate(ch_provider_description = dplyr::case_when( # from social care syntax
      ch_provider == 1 ~ "LOCAL AUTHORITY/HSCP/NHS BOARD",
      ch_provider == 2 ~ "PRIVATE",
      ch_provider == 3 ~ "OTHER LOCAL AUTHORITY",
      ch_provider == 4 ~ "THIRD SECTOR",
      ch_provider == 5 ~ "NHS BOARD",
      ch_provider == 6 ~ "OTHER"
    )) %>%
    dplyr::select(
      "chi",
      "person_id",
      "gender",
      "dob",
      "postcode",
      "sending_location",
      "social_care_id",
      "ch_name",
      "ch_postcode",
      "record_keydate1",
      "record_keydate2",
      "ch_chi_cis",
      "ch_sc_id_cis",
      "ch_provider",
      "ch_provider_description",
      "ch_nursing",
      "ch_adm_reason",
      "sc_latest_submission"
    ) %>%
    slfhelper::get_anon_chi()

  if (write_to_disk) {
    ch_data_final %>%
      write_file(get_sc_ch_episodes_path(check_mode = "write"))
  }

  return(ch_data_final)
}
