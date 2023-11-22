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


  # Data Cleaning ---------------------------------------
# TODO social care demographics - tidy up  code and make more efficient.
  sc_demog <- data %>%
    dplyr::mutate(
      # if one chi is missing then use the other
      # TODO social care demographics - decide what to do with cases where last 4 digits of chi are different
      chi_upi = ifelse(is.na(chi_upi), upi, chi_upi),
      upi = ifelse(is.na(upi), chi_upi, upi),
      submitted_date_of_birth = ifelse(is.na(submitted_date_of_birth), chi_date_of_birth, submitted_date_of_birth),
      chi_date_of_birth = ifelse(is.na(chi_date_of_birth), submitted_date_of_birth, chi_date_of_birth),
      chi_date_of_birth = lubridate::as_date(chi_date_of_birth),
      submitted_date_of_birth = lubridate::as_date(submitted_date_of_birth),
      # check gender code - replace code 99 with 9=

      # use CHI sex if available
       # TODO social care demographics - check gender matches chi for extra validation check
      submitted_gender = replace(.data$submitted_gender, .data$submitted_gender == 99L, 9L),
      gender = dplyr::if_else(
        is.na(.data$chi_gender_code) | .data$chi_gender_code == 9L,
        .data$submitted_gender,
        .data$chi_gender_code
      )
    ) %>%
    # format postcodes using `phsmethods`
    dplyr::mutate(dplyr::across(
      tidyselect::contains("postcode"),
      ~ phsmethods::format_postcode(.x, format = "pc7"))) %>%
    dplyr::distinct() %>%
    # if only one option is available for chi then choose that
    dplyr::mutate(chi = ifelse(chi_upi == upi | is.na(upi), chi_upi,
                               ifelse(is.na(chi_upi), upi, NA)
                               )) %>%
    dplyr::mutate(
      # if only one option is available for DOB then choose that
      dob = ifelse(chi_date_of_birth == submitted_date_of_birth | is.na(submitted_date_of_birth), chi_date_of_birth,
        ifelse(is.na(chi_date_of_birth), submitted_date_of_birth, NA)),
      dob = lubridate::as_date(dob)
    ) %>%
    dplyr::arrange(chi, dob) %>%
    dplyr::group_by(social_care_id, sending_location) %>%
    tidyr::fill(chi, .direction = c("down")) %>%
    tidyr::fill(dob, .direction = c("down")) %>%
    dplyr::ungroup() %>%
  # create string for DOB from CHI and the DOB to see if they match.
  dplyr::mutate(dob_from_chiupi = paste0(stringr::str_sub(chi, 1, 6))) %>%
    dplyr::mutate(dob_from_dob = paste0(
      stringr::str_sub(as.character(dob), 9, 10),
      stringr::str_sub(as.character(dob), 6, 7),
      stringr::str_sub(as.character(dob), 3, 4)
    )) %>%
    # validation flag. if dob goes with chi then flag as 1
    dplyr::mutate(chi_validation = ifelse(dob_from_chiupi == dob_from_dob, 1, 0))

# cases where all chi and dob are missing, nothing we can do about these and no validation
  missing <- sc_demog %>%
    dplyr::filter(is.na(chi_upi) & is.na(upi) & is.na(submitted_date_of_birth) & is.na(chi_date_of_birth) & is.na(chi) & is.na(dob)) %>%
    dplyr::select(-dob_from_chiupi, -dob_from_dob, -chi_upi, -upi, -chi_date_of_birth, -submitted_date_of_birth)

  # cases where chi and dob match
  validated <- sc_demog %>%
    dplyr::filter(chi_validation == 1) %>%
    dplyr::select(-dob_from_chiupi, -dob_from_dob, -chi_upi, -upi, -chi_date_of_birth, -submitted_date_of_birth)

  # match on either dob to chi
  sc_demog <- sc_demog %>%
    dplyr::anti_join(missing) %>%
    dplyr::filter(chi_validation != 1) %>%
    # get dob from chi and submitted and see if either match with chi
    dplyr::mutate(dob_from_chidob = paste0(
      stringr::str_sub(as.character(chi_date_of_birth), 9, 10),
      stringr::str_sub(as.character(chi_date_of_birth), 6, 7),
      stringr::str_sub(as.character(chi_date_of_birth), 3, 4)
    )) %>%
    dplyr::mutate(dob_from_submitteddob = paste0(
      stringr::str_sub(submitted_date_of_birth, 9, 10),
      stringr::str_sub(as.character(submitted_date_of_birth), 6, 7),
      stringr::str_sub(as.character(submitted_date_of_birth), 3, 4)
    )) %>%
    # if either dob matches with chi then use that dob
    dplyr::mutate(
      dob = ifelse(dob_from_chiupi == dob_from_chidob, chi_date_of_birth, dob),
      dob = ifelse(dob_from_chiupi == dob_from_submitteddob, submitted_date_of_birth, dob),
      dob = lubridate::as_date(dob)
    ) %>%
    dplyr::mutate(dob_from_dob = paste0(
      stringr::str_sub(as.character(dob), 9, 10),
      stringr::str_sub(as.character(dob), 6, 7),
      stringr::str_sub(as.character(dob), 3, 4)
    )) %>%
    # if dob and chi match then flag as validated
    dplyr::mutate(chi_validation = ifelse(dob_from_chiupi == dob_from_dob, 1, 0)) %>%
    dplyr::select(-dob_from_chidob, -dob_from_submitteddob)

# add the validated cases to validated df
  validated <- validated %>%
    rbind(sc_demog %>%
      dplyr::filter(chi_validation == 1) %>%
      dplyr::select(-dob_from_chiupi, -dob_from_dob, -chi_upi, -upi, -chi_date_of_birth, -submitted_date_of_birth))

  # match on dob to either chi
  sc_demog <- sc_demog %>%
    dplyr::filter(chi_validation != 1) %>%
    # create dob from both chi numbers
    dplyr::mutate(dob_from_upi = paste0(stringr::str_sub(upi, 1, 6))) %>%
    dplyr::mutate(dob_from_chi_upi = paste0(stringr::str_sub(chi_upi, 1, 6))) %>%
    # use whichever one matches
    dplyr::mutate(chi = ifelse(dob_from_chi_upi == dob_from_dob, chi_upi, chi)) %>%
    dplyr::mutate(chi = ifelse(dob_from_upi == dob_from_dob, upi, chi)) %>%
    dplyr::mutate(dob_from_chi = paste0(stringr::str_sub(chi, 1, 6))) %>%
    # if chi and dob match then flag as validated
    dplyr::mutate(chi_validation = ifelse(dob_from_chi == dob_from_dob, 1, 0))

  # all validated cases
  validated <- validated %>%
    rbind(sc_demog %>%
      dplyr::filter(chi_validation == 1) %>%
      dplyr::select(-dob_from_chiupi, -dob_from_upi, -dob_from_chi_upi, -dob_from_dob, -chi_upi, -upi, -chi_date_of_birth, -submitted_date_of_birth, -dob_from_chi))


  # TODO social care demographics - decide what to do with non-validated chi and cases where dob does not match chi
  # Need to decide what to do with social care cases where the chi and the dob do not match.
  # this is why I have kept the validated/non-validated df seperate. Hoping we can get back and sort this out.
  sc_demog <- sc_demog %>%
    dplyr::filter(chi_validation != 1) %>%   # all unvalidated cases. most of these are due to missing chi or dob so there is no way to validate.
    dplyr::select(-dob_from_chiupi, -dob_from_upi, -dob_from_chi_upi, -dob_from_dob, -chi_upi, -upi, -chi_date_of_birth, -submitted_date_of_birth, -dob_from_chi) %>%
    rbind(validated) %>%
    rbind(missing)


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
      "latest_record_flag",
      "extract_date",
      "sending_location",
      "social_care_id",
      "chi",
      "gender",
      "dob",
      "submitted_postcode",
      "chi_postcode"
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
  sc_demog %>%
    dplyr::count(.data$postcode_type)

  # count number of replaced postcode - compare with count above
  na_replaced_postcodes <- sc_demog %>%
    dplyr::count(dplyr::across(tidyselect::ends_with("_postcode"), ~ is.na(.x)))


  sc_demog_lookup <- sc_demog %>%
    # group by sending location and ID
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    # arrange so latest submissions are last
    # TODO social care demographics - there are data quality issues with `latest_record_flag`, `extract_date` and `period` in demographics
    # so there is currently (22/11/23) no completely accurate way to choose the latest record
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$latest_record_flag,
      .data$extract_date
    ) %>%
    # summarise to select the last (non NA) submission
    dplyr::summarise(
      chi = dplyr::last(.data$chi),
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
