#' Process the social care demographic lookup
#'
#' @description This will read and process the
#' social care demographic lookup, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process.
#' @param spd_path Path to the Scottish Postcode Directory.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_sc_demographics <- function(
    data,
    spd_path = get_spd_path(),
    write_to_disk = TRUE) {
  # Deal with postcodes ---------------------------------------

  # UK postcode regex - see https://ideal-postcodes.co.uk/guides/postcode-validation
  uk_pc_regexp <- "^[A-Z]{1,2}[0-9][A-Z0-9]?\\s*[0-9][A-Z]{2}$"

  dummy_postcodes <- c("NK1 0AA", "NF1 1AB")
  non_existant_postcodes <- c("PR2 5AL", "M16 0GS", "DY103DJ")

  valid_spd_postcodes <- read_file(spd_path, col_select = "pc7") %>%
    dplyr::pull(.data$pc7)


  #  Fill in missing data and flag latest cases to keep ---------------------------------------
  sc_demog <- data %>%
    dplyr::rename(
      chi = .data$chi_upi,
      gender = .data$chi_gender_code,
      dob = .data$chi_date_of_birth
    ) %>%
    # fill in missing demographic details
    dplyr::arrange(.data$period, .data$social_care_id) %>%
    dplyr::group_by(.data$social_care_id, .data$sending_location) %>%
    tidyr::fill(.data$chi, .direction = ("updown")) %>%
    tidyr::fill(.data$dob, .direction = ("updown")) %>%
    tidyr::fill(.data$date_of_death, .direction = ("updown")) %>%
    tidyr::fill(.data$gender, .direction = ("updown")) %>%
    tidyr::fill(.data$chi_postcode, .direction = ("updown")) %>%
    tidyr::fill(.data$submitted_postcode, .direction = ("updown")) %>%
    dplyr::ungroup() %>%
    # format postcodes using `phsmethods`
    dplyr::mutate(dplyr::across(tidyselect::contains("postcode"), ~ phsmethods::format_postcode(.x, format = "pc7"))) # are sc postcodes even used anywhere?


  # flag unique cases of chi and sc_id, and flag the latest record (sc_demographics latest flag is not accurate)
  sc_demog <- sc_demog %>%
    dplyr::group_by(.data$chi, .data$sending_location) %>%
    dplyr::mutate(latest = dplyr::last(.data$period)) %>% # flag latest period for chi
    dplyr::group_by(.data$chi, .data$social_care_id, .data$sending_location) %>%
    dplyr::mutate(latest_sc_id = dplyr::last(.data$period)) %>% # flag latest period for social care
    dplyr::group_by(.data$chi, .data$sending_location) %>%
    dplyr::mutate(last_sc_id = dplyr::last(.data$social_care_id)) %>%
    dplyr::mutate(
      latest_flag = ifelse((.data$latest == .data$period & .data$last_sc_id == .data$social_care_id) | is.na(.data$chi), 1, 0),
      keep = ifelse(.data$latest_sc_id == .data$period, 1, 0)
    ) %>%
    dplyr::ungroup()

  sc_demog <- sc_demog %>%
    dplyr::select(-.data$period, -.data$latest_record_flag, -.data$latest, -.data$last_sc_id, -.data$latest_sc_id) %>%
    dplyr::distinct()

  # postcodes ---------------------------------------------------------------

  # count number of na postcodes
  na_postcodes <- sc_demog %>%
    dplyr::count(dplyr::across(tidyselect::contains("postcode"), ~ is.na(.x)))

  sc_demog <- sc_demog %>%
    # remove dummy postcodes invalid postcodes missed by regex check
    dplyr::mutate(dplyr::across(
      tidyselect::ends_with("_postcode"),
      ~ dplyr::if_else(.x %in% c(dummy_postcodes, non_existant_postcodes), NA, .x)
    )) %>%
    # comparing with regex UK postcode
    dplyr::mutate(dplyr::across(
      tidyselect::ends_with("_postcode"),
      ~ dplyr::if_else(stringr::str_detect(.x, uk_pc_regexp), .x, NA)
    )) %>%
    dplyr::select(
      "sending_location",
      "social_care_id",
      "chi",
      "gender",
      "dob",
      "date_of_death",
      "submitted_postcode",
      "chi_postcode",
      "keep",
      "latest_flag"
    ) %>%
    # check if submitted_postcode matches with postcode lookup
    dplyr::mutate(
      valid_pc_submitted = .data$submitted_postcode %in% valid_spd_postcodes,
      valid_pc_chi = .data$chi_postcode %in% valid_spd_postcodes
    ) %>%
    # use submitted_postcode if valid, otherwise use chi_postcode
    dplyr::mutate(postcode = dplyr::case_when(
      (!is.na(.data$chi_postcode) & .data$valid_pc_chi) ~ .data$chi_postcode,
      ((is.na(.data$chi_postcode) | !(.data$valid_pc_chi)) & !(is.na(.data$submitted_postcode)) & .data$valid_pc_submitted) ~ .data$submitted_postcode,
      (is.na(.data$submitted_postcode) & !.data$valid_pc_submitted) ~ .data$chi_postcode
    )) %>%
    dplyr::mutate(postcode_type = dplyr::case_when(
      (.data$postcode == .data$chi_postcode) ~ "chi",
      (.data$postcode == .data$submitted_postcode) ~ "submitted",
      (is.na(.data$submitted_postcode) & is.na(.data$chi_postcode) | is.na(.data$postcode)) ~ "missing"
    ))

  # Check where the postcodes are coming from
  sc_demog %>%
    dplyr::count(.data$postcode_type)

  # count number of replaced postcode - compare with count above
  na_replaced_postcodes <- sc_demog %>%
    dplyr::count(dplyr::across(tidyselect::ends_with("_postcode"), ~ is.na(.x)))

  sc_demog_lookup <- sc_demog %>%
    dplyr::filter(.data$keep == 1) %>% # filter to only keep latest record for sc id and chi
    dplyr::select(-.data$postcode_type, -.data$valid_pc_submitted, -.data$valid_pc_chi, -.data$submitted_postcode, -.data$chi_postcode) %>%
    dplyr::distinct() %>%
    # group by sending location and ID
    dplyr::group_by(.data$sending_location, .data$chi, .data$social_care_id, .data$latest_flag) %>%
    # arrange so latest submissions are last
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$latest_flag
    ) %>%
    # summarise to select the last (non NA) submission
    dplyr::summarise(
      gender = dplyr::last(.data$gender),
      dob = dplyr::last(.data$dob),
      postcode = dplyr::last(.data$postcode),
      date_of_death = dplyr::last(.data$date_of_death)
    ) %>%
    dplyr::ungroup()

  # check to make sure all cases of chi are still there
  dplyr::n_distinct(sc_demog_lookup$chi) # 525,834
  dplyr::n_distinct(sc_demog_lookup$social_care_id) # 637,422


  if (write_to_disk) {
    write_file(
      sc_demog_lookup,
      get_sc_demog_lookup_path(check_mode = "write")
    )
  }

  return(sc_demog_lookup)
}
