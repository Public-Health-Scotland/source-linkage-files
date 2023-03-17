#' Process the all Care Home extract
#'
#' @description This will read and process the
#' all Care Home extract, it will return the final data
#' but also write this out as a rds.
#'
#' @param data The extract to process
#' @param sc_demographics The sc demographics lookup.
#' @param slf_deaths_path The path to slf deaths lookup.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
#' @export
#'
process_sc_all_care_home <- function(data,
                                     sc_demographics = get_sc_demog_lookup_path(),
                                     slf_deaths_path = get_slf_deaths_path(),
                                     write_to_disk = TRUE) {
  # Read Demographic file----------------------------------------------------

  sc_demographics <- readr::read_rds(sc_demographics)

  # Read slf deaths file----------------------------------------------------

  slf_deaths <- readr::read_rds(slf_deaths_path)


  ## Data Cleaning-----------------------------------------------------
  ch_clean <- data %>%
    dplyr::mutate(
      dplyr::across(
        c(
          "ch_provider",
          "reason_for_admission",
          "type_of_admission",
          "nursing_care_provision"
        ),
        as.integer
      ),
      record_date = end_fy_quarter(.data[["period"]]),
      qtr_start = start_fy_quarter(.data[["period"]]),
      # Set missing admission date to start of the submitted quarter
      ch_admission_date = dplyr::if_else(
        is.na(.data[["ch_admission_date"]]),
        .data[["qtr_start"]],
        .data[["ch_admission_date"]]
      ),
      # TODO check if we should set the dis date to the end of the period?
      # If the dis date is before admission, remove the dis date
      ch_discharge_date = dplyr::if_else(
        .data[["ch_admission_date"]] > .data[["ch_discharge_date"]],
        lubridate::NA_Date_,
        .data[["ch_discharge_date"]]
      )
    ) %>%
    dplyr::left_join(sc_demographics,
      by = c("sending_location", "social_care_id")
    )

  name_postcode_clean <- fill_ch_names(ch_clean)

  fixed_ch_provider <- name_postcode_clean %>%
    # sort data
    dplyr::arrange(
      "sending_location",
      "social_care_id",
      "ch_admission_date",
      "period"
    ) %>%
    dplyr::mutate(
      min_ch_provider = min(.data[["ch_provider"]]),
      max_ch_provider = max(.data[["ch_provider"]]),
      ch_provider = dplyr::if_else(
        .data[["min_ch_provider"]] != .data[["max_ch_provider"]],
        6L,
        .data[["ch_provider"]]
      )
    ) %>%
    dplyr::select(
      -"min_ch_provider",
      -"max_ch_provider"
    )

  fixed_sc_id <- fixed_ch_provider %>%
    replace_sc_id_with_latest()

  fixed_nursing_provision <- fixed_sc_id %>%
    dplyr::group_by(
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["ch_admission_date"]]
    ) %>%
    # fill in nursing care provision when missing
    # but present in the following entry
    dplyr::mutate(
      nursing_care_provision = dplyr::na_if(.data[["nursing_care_provision"]], 9L)
    ) %>%
    tidyr::fill(.data[["nursing_care_provision"]], .direction = "downup") %>%
    # tidy up ch_provider using 6 when disagreeing values
    tidyr::fill(.data[["ch_provider"]], .direction = "downup")

  ready_to_merge <- fixed_nursing_provision %>%
    # remove any duplicate records before merging for speed and simplicity
    dplyr::distinct() %>%
    # counter for split episodes
    dplyr::mutate(
      split_episode = tidyr::replace_na(
        .data[["nursing_care_provision"]] != dplyr::lag(
          .data[["nursing_care_provision"]]
        ),
        TRUE
      ),
      split_episode_counter = cumsum(.data[["split_episode"]])
    ) %>%
    dplyr::ungroup()

  # Merge records to a single row per episode
  # where admission is the same
  ch_episode <- ready_to_merge %>%
    # when nursing_care_provision is different on
    # records within the episode, split the episode
    # at this point.
    dplyr::group_by(
      .data[["chi"]],
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["ch_admission_date"]],
      .data[["nursing_care_provision"]],
      .data[["split_episode_counter"]]
    ) %>%
    dplyr::summarise(
      sc_latest_submission = dplyr::last("period"),
      dplyr::across(
        c(
          "ch_discharge_date",
          "ch_provider",
          "record_date",
          "qtr_start",
          "ch_name",
          "ch_postcode",
          "reason_for_admission",
          "type_of_admission"
        ),
        dplyr::last
      ),
      dplyr::across(c("gender", "dob", "postcode"), dplyr::first)
    ) %>%
    dplyr::ungroup() %>%
    # Amend dates for split episodes
    # Change the start and end date as appropriate when an episode is split,
    # using the start / end date of the submission quarter
    dplyr::group_by(
      .data[["chi"]],
      .data[["sending_location"]],
      .data[["social_care_id"]],
      .data[["ch_admission_date"]]
    ) %>%
    # counter for latest submission
    # TODO check if this is the same as split_episode_counter?
    dplyr::mutate(
      latest_submission_counter = tidyr::replace_na(
        .data[["sc_latest_submission"]] != dplyr::lag(
          .data[["sc_latest_submission"]]
        ),
        TRUE
      ),
      sum_latest_submission = cumsum(.data[["latest_submission_counter"]])
    ) %>%
    dplyr::mutate(
      # If it's the first episode(s) then keep the admission date(s),
      # otherwise use the start of the quarter
      ch_admission_date = dplyr::if_else(
        .data[["sum_latest_submission"]] == min(.data[["sum_latest_submission"]]),
        .data[["ch_admission_date"]],
        .data[["qtr_start"]]
      ),
      # If it's the last episode(s) then keep the discharge date(s), otherwise
      # use the end of the quarter
      ch_discharge_date = dplyr::if_else(
        .data[["sum_latest_submission"]] == max(.data[["sum_latest_submission"]]),
        .data[["ch_discharge_date"]],
        .data[["record_date"]]
      )
    ) %>%
    dplyr::ungroup()

  # Compare to Deaths Data
  # match ch_episode data with deaths data
  matched_deaths_data <- ch_episode %>%
    dplyr::left_join(slf_deaths,
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
    dplyr::filter(
      !tidyr::replace_na(
        .data[["ch_discharge_date"]] < .data[["ch_admission_date"]],
        FALSE
      )
    )

  # Continuous Care Home Stays
  # Stay will be continuous as long as the admission date is the next day or
  # earlier than the previous discharge date

  ch_markers <- matched_deaths_data %>%
    # ch_chi_cis
    dplyr::group_by(.data[["chi"]]) %>%
    dplyr::mutate(
      continuous_stay_chi = tidyr::replace_na(
        .data[["ch_admission_date"]] <= dplyr::lag(
          .data[["ch_discharge_date"]]
        ) + lubridate::days(1L),
        TRUE
      ),
      ch_chi_cis = cumsum(.data[["continuous_stay_chi"]])
    ) %>%
    dplyr::ungroup() %>%
    # ch_sc_id_cis
    # uses the social care id and sending location so can be used for
    # episodes that are not attached to a CHI number
    # This will restrict continuous stays to each Local Authority
    dplyr::group_by(.data[["social_care_id"]], .data[["sending_location"]]) %>%
    dplyr::mutate(
      continuous_stay_sc = tidyr::replace_na(
        .data[["ch_admission_date"]] <= dplyr::lag(
          .data[["ch_discharge_date"]]
        ) + lubridate::days(1L),
        TRUE
      ),
      ch_sc_id_cis = cumsum(.data[["continuous_stay_sc"]])
    ) %>%
    dplyr::ungroup()

  # Do a recode on the old reason for admission
  adm_reason_recoded <- ch_markers %>%
    dplyr::group_by(
      .data[["social_care_id"]],
      .data[["sending_location"]],
      .data[["ch_sc_id_cis"]]
    ) %>%
    dplyr::mutate(
      ch_ep_start = min(.data[["ch_admission_date"]]),
      ch_ep_end = max(
        pmin(
          .data[["record_date"]],
          .data[["ch_discharge_date"]],
          na.rm = TRUE
        )
      )
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      stay_los = lubridate::time_length(
        lubridate::interval(.data[["ch_ep_start"]], .data[["ch_ep_end"]]),
        "weeks"
      ),
      stay_respite = .data[["stay_los"]] < 6.0,
      type_of_admission = dplyr::if_else(
        is.na(.data[["type_of_admission"]]),
        dplyr::case_when(
          .data[["reason_for_admission"]] == 1L ~ 1L,
          .data[["reason_for_admission"]] == 2L ~ 2L,
          stay_respite ~ 1L,
          .default = 3L
        ),
        .data[["type_of_admission"]]
      )
    )

  outfile <- adm_reason_recoded %>%
    create_person_id() %>%
    dplyr::rename(
      record_keydate1 = "ch_admission_date",
      record_keydate2 = "ch_discharge_date",
      ch_adm_reason = "type_of_admission",
      ch_nursing = "nursing_care_provision"
    ) %>%
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
      "ch_nursing",
      "ch_adm_reason",
      "sc_latest_submission"
    )

  if (write_to_disk) {
    outfile %>%
      write_rds(get_sc_ch_episodes_path(check_mode = "write"))
  }
}