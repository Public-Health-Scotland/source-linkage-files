#' Process the all SDS extract
#' @description This will read and process the
#' all SDS extract, it will return the final data
#' but also write this out as a rds.
#'
#' @param data The extract to process
#' @param sc_demographics The sc demographics lookup. Default set to NULL as
#' we can pass this through data in the environment.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
#'
process_sc_all_home_care <- function(data, sc_demographics = NULL, write_to_disk = TRUE) {
  # Match on demographic data ---------------------------------------
  if (is.null(sc_demographics)) {
    # read in demographic data
    sc_demographics <- readr::read_rds(get_sc_demog_lookup_path())
  }

  # Match on demographics data (chi, gender, dob and postcode)
  matched_sds_data <- data %>%
    dplyr::left_join(sc_demographics, by = c("sending_location", "social_care_id"))

  # Data Cleaning ---------------------------------------

  sds_full_clean <- matched_sds_data %>%
    # Deal with SDS option 4
    # First turn the option flags into a logical T/F
    mutate(across(starts_with("sds_option_"), ~ case_when(
      .x == "1" ~ TRUE,
      .x == "0" ~ FALSE,
      is.na(.x) ~ FALSE
    ))) %>%
    # SDS option 4 is derived when a person receives more than one option.
    # e.g. if a person has options 1 and 2 then option 4 will be derived
    mutate(sds_option_4 = rowSums(across(starts_with("sds_option_"))) > 1, .after = sds_option_3) %>%
    # If sds start date is missing, assign start of FY
    mutate(sds_start_date = fix_sc_start_dates(sds_start_date, period)) %>%
    # Fix sds_end_date is earlier than sds_start_date by setting end_date to be the end of fyear
    mutate(sds_end_date = fix_sc_end_dates(sds_start_date, sds_end_date, period)) %>%
    # rename for matching source variables
    rename(
      record_keydate1 = sds_start_date,
      record_keydate2 = sds_end_date
    ) %>%
    # Pivot longer on sds option variables
    tidyr::pivot_longer(
      cols = contains("sds_option_"),
      names_to = "sds_option",
      names_prefix = "sds_option_",
      names_transform = list(sds_option = ~ paste0("SDS-", .x)),
      values_to = "received"
    ) %>%
    # Only keep rows where they received a package and remove duplicates
    filter(received) %>%
    distinct() %>%
    # Include source variables
    mutate(
      smrtype = case_when(
        sds_option == "SDS-1" ~ "SDS-1",
        sds_option == "SDS-2" ~ "SDS-2",
        sds_option == "SDS-3" ~ "SDS-3",
        sds_option == "SDS-4" ~ "SDS-4"
      ),
      recid = "SDS",
      # Create person id variable
      person_id = glue::glue("{sending_location}-{social_care_id}"),
      # Use function for creating sc send lca variables
      sc_send_lca = convert_sending_location_to_lca(sending_location)
    ) %>%
    # when multiple social_care_id from sending_location for single CHI
    # replace social_care_id with latest
    replace_sc_id_with_latest()

  merge_eps <- sds_full_clean %>%
    # use as.data.table to change the data format to data.table to accelarate
    data.table::as.data.table() %>%
    group_by(sending_location, social_care_id, sds_option) %>%
    arrange(period, record_keydate1, .by_group = TRUE) %>%
    # Create a flag for episodes that are going to be merged
    # Create an episode counter
    mutate(
      distinct_episode = (record_keydate1 > lag(record_keydate2)) %>%
        replace_na(TRUE),
      episode_counter = cumsum(distinct_episode)
    ) %>%
    # Group by episode counter and merge episodes
    group_by(episode_counter, .add = TRUE) %>%
    summarise(
      sc_latest_submission = last(period),
      record_keydate1 = min(record_keydate1),
      record_keydate2 = max(record_keydate2),
      sending_location = last(sending_location),
      social_care_id = last(social_care_id),
      chi = last(chi),
      gender = last(gender),
      dob = last(dob),
      postcode = last(postcode),
      smrtype = last(smrtype),
      recid = last(recid),
      person_id = last(person_id),
      sc_send_lca = last(sc_send_lca)
    ) %>%
    # change the data format from data.table to data.frame
    as_tibble() %>%
    # Save outfile------------------------------------------------
    if (write_to_disk) {
      merge_eps() %>%
        write_rds(get_sc_sds_episodes_path(check_mode = "write"))
    }
}
