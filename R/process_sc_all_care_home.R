#' Process the all Care Home extract
#'
#' @description This will read and process the
#' all Care Home extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process
#' @param sc_demog_lookup The Social Care Demographics lookup produced by
#' [process_lookup_sc_demographics()].
#' @param refined_death The processed lookup of deaths from IT produced
#' with [process_refined_death()].
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
    refined_death = read_file(get_combined_slf_deaths_lookup_path()) %>% slfhelper::get_chi(),
    ch_name_lookup_path = get_slf_ch_name_lookup_path(),
    spd_path = get_spd_path(),
    write_to_disk = TRUE) {
  ## Data Cleaning-----------------------------------------------------

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
    dplyr::right_join(sc_demog_lookup, # this is the correct join.
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
    # Changes in data definitions, 6 is no longer coded as 'other', this is now '5 = other'
    dplyr::mutate(
      ch_provider = dplyr::if_else(is.na(.data[["ch_provider"]]), 5L, .data[["ch_provider"]]) # (n = 2)
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
  matched_deaths_data <- ch_episode %>%
    dplyr::left_join(refined_death,
      by = "chi",
      na_matches = "never"
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
    # Group the data by chi
    dplyr::group_by(.data[["chi"]]) %>%
    # Set up previous_discharge_date
    # The lag function will set the first row to NA.
    dplyr::mutate(
      # We want to flag the first episode per chi with row_number
      row_number = dplyr::row_number(),
      # create variable for previous discharge date + 1 day
      previous_discharge_date_chi = dplyr::lag(.data[["ch_discharge_date"]]) +
        lubridate::days(1L),
      # if the first row is NA, set this to the ch_discharge_date
      previous_discharge_date_chi = dplyr::if_else(row_number == 1, .data[["ch_discharge_date"]],
        .data[["previous_discharge_date_chi"]]
      )
    ) %>%
    # flag continuous stays and create marker
    # calculate number of days between start_date and end_date on the previous episode
    dplyr::mutate(
      days_to_next_rec = floor(
        lubridate::time_length(lubridate::interval(
          .data[["previous_discharge_date_chi"]],
          .data[["ch_admission_date"]]
        ), "days")
      ),
      # if there is more than 1 day between (or the last ep for the individual) flag as new ep (Y)
      # if there is < 1 day (i.e. a pause of up to 1 day or stays overlap flag as same ep (N))
      new_episode = dplyr::if_else(is.na(days_to_next_rec) | days_to_next_rec > 1, "Y", "N")
    ) %>%
    # create continuous marker using flag for new stay
    dplyr::mutate(
      ch_chi_cis = purrr::accumulate(new_episode[-1],
        .init = 1,
        ~ if (.y == "Y") {
          .x + 1
        } else {
          .x
        }
      )
    ) %>%
    dplyr::ungroup()


  # This is the same but uses the social care id and sending location so can be used for
  # episodes that are not attached to a CHI number
  # This will restrict continuous stays to each Local Authority
  sc_ch_id_markers <- ch_chi_markers %>%
    # uses social_care_id and sending_location to flag continuous stays.
    # Will flag cases even if in another LA
    dplyr::group_by(.data[["social_care_id"]], .data[["sending_location"]]) %>%
    # Set up previous_discharge_date
    # The lag function will set the first row to NA.
    dplyr::mutate(
      # We want to flag the first episode per sc id and sending_location with row_number
      row_number = dplyr::row_number(),
      # create variable for previous discharge date + 1 day
      previous_discharge_date_sc = dplyr::lag(.data[["ch_discharge_date"]]) +
        lubridate::days(1L),
      # if the first row is NA, set this to the ch_discharge_date
      previous_discharge_date_sc = dplyr::if_else(row_number == 1, .data[["ch_discharge_date"]],
        .data[["previous_discharge_date_sc"]]
      )
    ) %>%
    # flag continuous stays and create marker
    # calculate number of days between start_date and end_date on the previous episode
    dplyr::mutate(
      days_to_next_rec = floor(
        lubridate::time_length(lubridate::interval(
          .data[["previous_discharge_date_sc"]],
          .data[["ch_admission_date"]]
        ), "days")
      ),
      # if there is more than 1 day between (or the last ep for the individual) flag as new ep (Y)
      # if there is < 1 day (i.e. a pause of up to 1 day or stays overlap flag as same ep (N))
      new_episode = dplyr::if_else(is.na(days_to_next_rec) | days_to_next_rec > 1, "Y", "N")
    ) %>%
    # create continuous marker using flag for new stay
    dplyr::mutate(
      ch_sc_id_cis = purrr::accumulate(new_episode[-1],
        .init = 1,
        ~ if (.y == "Y") {
          .x + 1
        } else {
          .x
        }
      )
    ) %>%
    dplyr::ungroup() %>%
    # remove variables no longer needed
    dplyr::select(
      -previous_discharge_date_chi, -previous_discharge_date_sc, -row_number,
      -days_to_next_rec, -new_episode
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
