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
  sc_demog1 <- sc_demog %>%
    # sc_demog <- data %>%
    dplyr::rename(
      upi = chi_upi,
      gender = chi_gender_code,
      dob = chi_date_of_birth
    ) %>%
    # fill in missing demographic details
    dplyr::arrange(period, social_care_id) %>%
    dplyr::group_by(social_care_id, sending_location) %>%
    tidyr::fill(upi, .direction = ("updown")) %>%
    tidyr::fill(dob, .direction = ("updown")) %>%
    tidyr::fill(date_of_death, .direction = ("updown")) %>%
    tidyr::fill(gender, .direction = ("updown")) %>%
    tidyr::fill(chi_postcode, .direction = ("updown")) %>%
    tidyr::fill(submitted_postcode, .direction = ("updown")) %>%
    # format postcodes using `phsmethods`
    dplyr::mutate(dplyr::across(tidyselect::contains("postcode"), ~ phsmethods::format_postcode(.x, format = "pc7"))) # are sc postcodes even used anywhere?

  # 4924132
  # 4946071
  # flag unique cases of chi and sc_id, and flag the latest record (sc_demographics latest flag is not accurate)
  sc_demog2 <- sc_demog1 %>%
    dplyr::group_by(upi) %>%
    dplyr::mutate(latest = dplyr::last(period)) %>% # flag latest period for chi
    dplyr::group_by(upi, social_care_id) %>%
    dplyr::mutate(latest_sc_id = dplyr::last(period)) %>% # flag latest period for social care
    dplyr::group_by(upi) %>%
    dplyr::mutate(
      latest_flag = ifelse(latest == period | is.na(upi), 1, 0),
      keep = ifelse(latest_sc_id == period, 1, 0)
    ) #

  # dplyr::n_distinct(sc_demog2$upi) # 524810
  # dplyr::n_distinct(sc_demog2$social_care_id) # 636404

  sc_demog3 <- sc_demog2 %>%
    dplyr::filter(keep == 1) %>% # filter to only keep latest record for sc id and chi
    dplyr::group_by(upi, social_care_id) %>%
    dplyr::select(-period, -latest_record_flag, -latest, -latest_sc_id, -keep) %>%
    dplyr::distinct() %>%
    dplyr::ungroup()

  test <- sc_demog3 %>%
    dplyr::group_by(social_care_id, sending_location) %>%
    dplyr::mutate(count_scid = dplyr::n()) %>%
    dplyr::group_by(upi)

  # check to make sure all cases of chi are still there
  # dplyr::n_distinct(sc_demog3$upi) # 524810
  # dplyr::n_distinct(sc_demog3$social_care_id) # 636404


  # postcodes ---------------------------------------------------------------

  # count number of na postcodes
  na_postcodes1 <- sc_demog3 %>%
    dplyr::count(dplyr::across(tidyselect::contains("postcode"), ~ is.na(.x)))

  sc_demog4 <- sc_demog3 %>%
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
      "upi",
      "gender",
      "dob",
      "date_of_death",
      "submitted_postcode",
      "chi_postcode",
      "period", "latest_record_flag", "latest", "latest_sc_id", "keep",
      "latest_flag"
    ) %>%
    # check if submitted_postcode matches with postcode lookup
    dplyr::mutate(
      valid_pc = .data$submitted_postcode %in% valid_spd_postcodes
    ) %>%
    # use submitted_postcode if valid, otherwise use chi_postcode
    dplyr::mutate(postcode = dplyr::case_when(
      (!is.na(.data$submitted_postcode) & .data$valid_pc) ~ .data$submitted_postcode,
      (is.na(.data$submitted_postcode) & !.data$valid_pc) ~ .data$chi_postcode
    )) %>%
    dplyr::mutate(postcode_type = dplyr::case_when(
      (!is.na(.data$submitted_postcode) & .data$valid_pc) ~ "submitted",
      (is.na(.data$submitted_postcode) & !.data$valid_pc) ~ "chi",
      (is.na(.data$submitted_postcode) & is.na(.data$chi_postcode)) ~ "missing"
    ))

  # Check where the postcodes are coming from
  sc_demog4 %>%
    dplyr::count(.data$postcode_type)

  # count number of replaced postcode - compare with count above
  na_replaced_postcodes <- sc_demog4 %>%
    dplyr::count(dplyr::across(tidyselect::ends_with("_postcode"), ~ is.na(.x)))


  sc_demog_lookup <- sc_demog4 %>%
    dplyr::filter(keep == 1) %>% # filter to only keep latest record for sc id and chi
    dplyr::select(-period, -latest_record_flag, -latest, -latest_sc_id, -keep) %>%
    dplyr::group_by(upi, social_care_id) %>%
    dplyr::distinct() %>%
    # dplyr::ungroup()
    # group by sending location and ID
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    # arrange so latest submissions are last
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$latest_flag
    ) %>%
    # summarise to select the last (non NA) submission
    dplyr::summarise(
      chi = dplyr::last(.data$upi),
      gender = dplyr::last(.data$gender),
      dob = dplyr::last(.data$dob),
      postcode = dplyr::last(.data$postcode)
    ) %>%
    dplyr::ungroup()

  if (write_to_disk) {
    write_file(
      sc_demog_lookup,
      get_sc_demog_lookup_path(check_mode = "write")
    )
  }

  return(sc_demog_lookup)
}
