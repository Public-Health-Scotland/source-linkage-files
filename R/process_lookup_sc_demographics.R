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

  data <- data %>%
    # add per in social_care_id in Renfrewshire
    fix_scid_renfrewshire() %>%
    # create financial_year and financial_quarter variables for sorting
    dplyr::mutate(
      financial_year = as.numeric(stringr::str_sub(period, 1, 4)),
      financial_quarter = stringr::str_sub(period, 6, 6)
    ) %>%
    # set financial quarter to 5 when there is only an annual submission -
    # for ordering periods with annual submission last
    dplyr::mutate(
      financial_quarter = dplyr::if_else(
        is.na(financial_quarter) |
          financial_quarter == "",
        "5",
        financial_quarter
      )
    ) %>%
    # arrange - makes sure extract date is last
    dplyr::arrange(
      sending_location,
      social_care_id,
      financial_year,
      financial_quarter,
      extract_date
    ) %>%
    dplyr::relocate(c(financial_year, financial_quarter), .after = period)

  #  Fill in missing data and flag latest cases to keep ---------------------------------------
  sc_demog <- data %>%
    dplyr::rename(
      anon_chi = .data$anon_chi,
      gender = .data$chi_gender_code,
      dob = .data$chi_date_of_birth
    ) %>%
    # fill in missing demographic details
    dplyr::arrange(.data$period, .data$social_care_id) %>%
    dplyr::group_by(.data$social_care_id, .data$sending_location) %>%
    tidyr::fill(.data$anon_chi, .direction = ("updown")) %>%
    tidyr::fill(.data$dob, .direction = ("updown")) %>%
    tidyr::fill(.data$date_of_death, .direction = ("updown")) %>%
    tidyr::fill(.data$gender, .direction = ("updown")) %>%
    tidyr::fill(.data$chi_postcode, .direction = ("updown")) %>%
    tidyr::fill(.data$submitted_postcode, .direction = ("updown")) %>%
    dplyr::ungroup()

  ch_pc <- readxl::read_xlsx(get_slf_ch_name_lookup_path()) %>%
    dplyr::select(AccomPostCodeNo) %>%
    dplyr::rename(ch_pc = AccomPostCodeNo) %>%
    dplyr::mutate(ch_pc = phsmethods::format_postcode(ch_pc, quiet = TRUE)) %>%
    dplyr::filter(!is.na(ch_pc)) %>%
    dplyr::pull()

  # pre-clean postcode:
  # mainly remove care home postcode being supplied as home postcode
  sc_demog <- sc_demog %>%
    # format postcodes using `phsmethods`
    # are sc postcodes even used anywhere?
    dplyr::mutate(dplyr::across(
      tidyselect::contains("postcode"),
      ~ phsmethods::format_postcode(.x, format = "pc7", quiet = TRUE)
    )) %>%
    # remove care home pc where are supplied as home address
    # dplyr::mutate(dplyr::across(
    #   tidyselect::contains("postcode"),
    #   ~ dplyr::if_else(.x %in% ch_pc, NA, .x)
    # )) %>%
    dplyr::mutate(
      # check if pc is ch_pc
      is_sp_ch = (submitted_postcode %in% ch_pc),
      is_cp_ch = (chi_postcode %in% ch_pc),
      # store those ch_pc away and remove ch_pc
      submitted_postcode_ch = dplyr::if_else(is_sp_ch, submitted_postcode, NA),
      chi_postcode_ch = dplyr::if_else(is_cp_ch, chi_postcode, NA),
      submitted_postcode = dplyr::if_else(!is_sp_ch, submitted_postcode, NA),
      chi_postcode = dplyr::if_else(!is_cp_ch, chi_postcode, NA)
    ) %>%
    # fill old home postcode down, from older records for the person
    dplyr::arrange(
      "anon_chi",
      "sending_location",
      "social_care_id",
      "financial_year",
      "financial_quarter",
      "extract_date"
    ) %>%
    dplyr::group_by(.data$anon_chi, .data$sending_location, .data$social_care_id) %>%
    tidyr::fill(.data$submitted_postcode, .direction = "down") %>%
    tidyr::fill(.data$chi_postcode, .direction = "down") %>%
    dplyr::ungroup()

  # flag unique cases of chi and sc_id, and flag the latest record (sc_demographics latest flag is not accurate)
  sc_demog <- sc_demog %>%
    dplyr::group_by(.data$anon_chi, .data$sending_location) %>%
    dplyr::mutate(latest = dplyr::last(.data$period)) %>% # flag latest period for chi
    dplyr::group_by(.data$anon_chi, .data$social_care_id, .data$sending_location) %>%
    dplyr::mutate(latest_sc_id = dplyr::last(.data$period)) %>% # flag latest period for social care
    dplyr::group_by(.data$anon_chi, .data$sending_location) %>%
    dplyr::mutate(last_sc_id = dplyr::last(.data$social_care_id)) %>%
    dplyr::mutate(
      latest_flag = ifelse((.data$latest == .data$period & .data$last_sc_id == .data$social_care_id) | is.na(.data$anon_chi), 1, 0),
      keep = ifelse(.data$latest_sc_id == .data$period, 1, 0)
    ) %>%
    dplyr::ungroup() %>%
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
      "anon_chi",
      "gender",
      "dob",
      "date_of_death",
      "submitted_postcode",
      "chi_postcode",
      "submitted_postcode_ch",
      "chi_postcode_ch",
      "keep",
      "latest_flag",
      "extract_date"
    ) %>%
    # check if submitted_postcode matches with postcode lookup
    dplyr::mutate(
      valid_pc_submitted = .data$submitted_postcode %in% valid_spd_postcodes,
      valid_pc_chi = .data$chi_postcode %in% valid_spd_postcodes
    ) %>%
    # use submitted_postcode if valid, otherwise use chi_postcode
    dplyr::mutate(
      postcode = dplyr::case_when(
        (!is.na(.data$chi_postcode) &
          .data$valid_pc_chi) ~ .data$chi_postcode,
        ((
          is.na(.data$chi_postcode) |
            !(.data$valid_pc_chi)
        ) &
          !(is.na(
            .data$submitted_postcode
          )) & .data$valid_pc_submitted) ~ .data$submitted_postcode,
        (is.na(.data$submitted_postcode) &
          !.data$valid_pc_submitted) ~ .data$chi_postcode
      ),
      postcode_ch_as_home = dplyr::case_when(
        !is.na(.data$submitted_postcode_ch) ~ .data$submitted_postcode_ch,
        (is.na(.data$submitted_postcode_ch) &
          !is.na(.data$chi_postcode_ch)) ~ .data$chi_postcode_ch,
        (is.na(.data$submitted_postcode_ch) &
          !is.na(.data$chi_postcode_ch)) ~ NA
      ),
      postcode_ch_as_home = dplyr::if_else(is.na(postcode),
        postcode_ch_as_home,
        NA
      )
    ) %>%
    dplyr::mutate(postcode_type = dplyr::case_when(
      (.data$postcode == .data$chi_postcode) ~ "chi",
      (.data$postcode == .data$submitted_postcode) ~ "submitted",
      (
        is.na(.data$submitted_postcode) &
          is.na(.data$chi_postcode) | is.na(.data$postcode)
      ) ~ "missing"
    ))

  sc_demog <- sc_demog %>%
    dplyr::mutate(postcode = dplyr::if_else(
      is.na(postcode) & !is.na(postcode_ch_as_home),
      postcode_ch_as_home,
      postcode,
      postcode
    ))

  # Check where the postcodes are coming from
  sc_demog %>%
    dplyr::count(.data$postcode_type)

  # count number of replaced postcode - compare with count above
  na_replaced_postcodes <- sc_demog %>%
    dplyr::count(dplyr::across(tidyselect::ends_with("_postcode"), ~ is.na(.x)))

  sc_demog_lookup <- sc_demog %>%
    dplyr::filter(.data$keep == 1) %>% # filter to only keep latest record for sc id and chi
    dplyr::select(
      -.data$postcode_type,
      -.data$valid_pc_submitted,
      -.data$valid_pc_chi,
      -.data$submitted_postcode,
      -.data$chi_postcode
    ) %>%
    dplyr::distinct() %>%
    # group by sending location and ID
    dplyr::group_by(
      .data$sending_location,
      .data$anon_chi,
      .data$social_care_id,
      .data$latest_flag
    ) %>%
    # arrange so latest submissions are last
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$latest_flag,
      .data$extract_date
    ) %>%
    # summarize to select the last (non NA) submission
    dplyr::summarise(
      gender = dplyr::last(.data$gender),
      dob = dplyr::last(.data$dob),
      postcode = dplyr::last(.data$postcode),
      postcode_ch_as_home = dplyr::last(.data$postcode_ch_as_home),
      date_of_death = dplyr::last(.data$date_of_death),
      extract_date = dplyr::last(.data$extract_date)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(
      -"postcode_ch_as_home",
      -"extract_date"
    )

  # check to make sure all cases of chi are still there
  dplyr::n_distinct(sc_demog_lookup$anon_chi) # 525,834 # 573,427
  dplyr::n_distinct(sc_demog_lookup$social_care_id) # 637,422

  if (write_to_disk) {
    write_file(sc_demog_lookup,
      get_sc_demog_lookup_path(check_mode = "write"),
      group_id = 3206
    ) # hscdiip owner
  }

  return(sc_demog_lookup)
}
