#' Process the social care demographic lookup
#'
#' @description This will read and process the
#' social care demographic lookup, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process.
#' @param spd_path Path to the Scottish Postcode Directory.
#' @param uk_pc_path UK Postcode directory
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_sc_demographics <- function(
    data,
    all_care_home_extract,
    spd_path = get_spd_path(),
    uk_pc_path = get_uk_postcode_path(),
    write_to_disk = TRUE) {
  data <- data %>%
    # add per in social_care_id in Renfrewshire
    fix_scid_renfrewshire() %>%
    # create financial_year and financial_quarter variables for sorting
    add_fy_qtr_from_period()

  sc_demog <- data %>%
    # arrange - makes sure extract date is last
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$financial_year,
      .data$financial_quarter,
      .data$extract_date
    ) %>%
    dplyr::relocate(c("financial_year", "financial_quarter"), .after = "period") %>%
    dplyr::rename(
      gender = "chi_gender_code",
      dob = "chi_date_of_birth"
    ) %>%
    # fill in missing demographic details
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    tidyr::fill(
      "anon_chi",
      "dob",
      "date_of_death",
      "gender",
      "chi_postcode",
      "submitted_postcode",
      .direction = ("downup")
    ) %>%
    dplyr::ungroup()


  # remove postcode first -----
  # UK postcode regex - see https://ideal-postcodes.co.uk/guides/postcode-validation
  uk_pc_regexp <- "^[A-Z]{1,2}[0-9][A-Z0-9]?\\s*[0-9][A-Z]{2}$"

  dummy_postcodes <- c("NK1 0AA", "NF1 1AB")
  non_existant_postcodes <- c("PR2 5AL", "M16 0GS", "DY103DJ")

  valid_spd_postcodes <- read_file(spd_path, col_select = "pc7") %>%
    dplyr::pull(.data$pc7)
  valid_uk_postcodes <- read_file(uk_pc_path) %>%
    dplyr::pull()
  # combine them as some deleted scottish pc are not in the uk pc list
  valid_uk_postcodes <- union(valid_spd_postcodes, valid_uk_postcodes) %>%
    sort()

  ch_pc <- openxlsx::read.xlsx(get_slf_ch_name_lookup_path()) %>%
    dplyr::select("AccomPostCodeNo") %>%
    dplyr::rename("ch_pc" = "AccomPostCodeNo") %>%
    dplyr::mutate(ch_pc = phsmethods::format_postcode(.data$ch_pc, quiet = TRUE)) %>%
    dplyr::filter(!is.na(.data$ch_pc)) %>%
    dplyr::pull()


  sc_demog = sc_demog %>%
    dplyr::mutate(
      financial_year_extract = which_fy(.data$extract_date, format = "year")
    )

  all_care_home_extract = targets::tar_read("all_care_home_extract")
  client_in_ch = all_care_home_extract %>%
    dplyr::select("sending_location", "social_care_id","period") %>%
    add_fy_qtr_from_period() %>%
    dplyr::arrange(.data$sending_location,
                   .data$social_care_id,
                   .data$financial_year) %>%
    dplyr::distinct(.data$sending_location,
                    .data$social_care_id,
                    .data$financial_year) %>%
    mutate(living_in_ch = TRUE)

  # pre-clean postcode:
  # mainly remove care home postcode being supplied as home postcode
  sc_demog_ch <- sc_demog %>%
    # format postcodes using `phsmethods`
    dplyr::mutate(dplyr::across(
      tidyselect::contains("postcode"),
      ~ phsmethods::format_postcode(.x, format = "pc7", quiet = TRUE)
    )) %>%
    # remove dummy postcodes invalid postcodes missed by regex check
    dplyr::mutate(dplyr::across(
      tidyselect::contains("_postcode"),
      ~ dplyr::if_else(.x %in% c(dummy_postcodes, non_existant_postcodes), NA, .x)
    )) %>%
    # check if submitted_postcode matches with postcode lookup
    dplyr::mutate(
      submitted_postcode = dplyr::if_else(
        .data$submitted_postcode %in% valid_uk_postcodes,
        .data$submitted_postcode,
        NA
      ),
      chi_postcode = dplyr::if_else(
        .data$chi_postcode %in% valid_uk_postcodes,
        .data$chi_postcode,
        NA
      )
    ) %>%
    dplyr::left_join(client_in_ch,
                     by = c("sending_location", "social_care_id", "financial_year")) %>%
    # Scenario handled here:
    # someone began to live in care home from fy2022.
    # Postcode in the demog file submitted in fy 2022
    # for fy 2021 may be care home postcode, which is not correct.
    dplyr::left_join(
      client_in_ch %>%
        select(
          "sending_location",
          "social_care_id",
          "financial_year_extract" = "financial_year",
          "living_in_ch_extract" = "living_in_ch"
        ),
      by = c(
        "sending_location",
        "social_care_id",
        "financial_year_extract"
      )
    ) %>%
    relocate("submitted_postcode", .before = "chi_postcode") %>%
    dplyr::mutate(
      living_in_ch = tidyr::replace_na(.data$living_in_ch, FALSE),
      living_in_ch_extract = tidyr::replace_na(.data$living_in_ch_extract, FALSE),
      living_in_ch_combined = (living_in_ch | living_in_ch_extract),
      # check if pc is ch_pc
      is_sp_ch = (.data$submitted_postcode %in% ch_pc),
      is_cp_ch = (.data$chi_postcode %in% ch_pc),
      # store those ch_pc away and remove ch_pc
      submitted_postcode_ch = dplyr::if_else(
        .data$is_sp_ch & .data$living_in_ch_combined,
        .data$submitted_postcode,
        NA
      ),
      chi_postcode_ch = dplyr::if_else(
        .data$is_cp_ch & .data$living_in_ch_combined,
        .data$chi_postcode,
        NA
      ),
      submitted_postcode = dplyr::if_else(
        !(.data$is_sp_ch & .data$living_in_ch_combined),
        .data$submitted_postcode,
        NA
      ),
      chi_postcode = dplyr::if_else(
        !(.data$is_cp_ch & .data$living_in_ch_combined),
        .data$chi_postcode,
        NA
      )
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
    tidyr::fill("submitted_postcode", "chi_postcode", .direction = "down") %>%
    dplyr::ungroup() %>%

    dplyr::select(
      "financial_year",
      "financial_quarter",
      "period",
      "extract_date",
      "sending_location",
      "social_care_id",
      "anon_chi",
      "gender",
      "dob",
      "date_of_death",
      "submitted_postcode",
      "chi_postcode",
      "submitted_postcode_ch",
      "chi_postcode_ch"
    ) %>%
    # use submitted_postcode if valid, otherwise use chi_postcode
    dplyr::mutate(
      postcode = dplyr::case_when(
        !is.na(submitted_postcode) ~ submitted_postcode,
        !is.na(chi_postcode) ~ chi_postcode,
        .default = NA
      ),
      postcode_ch_as_home = dplyr::case_when(
        !is.na(.data$submitted_postcode_ch) ~ .data$submitted_postcode_ch,
        !is.na(.data$chi_postcode_ch) ~ .data$chi_postcode_ch,
        .default = NA
      ),
      postcode_type = dplyr::case_when(
        !is.na(submitted_postcode) ~ "submitted",
        !is.na(chi_postcode) ~ "chi",
        .default = "missing"
      ),
      postcode = dplyr::if_else(
        is.na(.data$postcode) & !is.na(.data$postcode_ch_as_home),
        .data$postcode_ch_as_home,
        .data$postcode,
        .data$postcode
      )
    ) %>%

    # arrange before missing data is filled in
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$financial_year,
      .data$financial_quarter,
      .data$extract_date
    ) %>%
    # add consistent_quality to indicate how long one social_care_id has been used
    # quality: The higher, the better.
    # This is to tackle the situation where
    # for one CHI, two different social_care_id submitted at the same latest date.
    dplyr::group_by(.data$sending_location,
                    .data$social_care_id,
                    .data$anon_chi) %>%
    dplyr::mutate(consistent_quality = dplyr::n_distinct(.data$period)) %>%
    dplyr::ungroup() %>%

    dplyr::group_by(.data$sending_location,
                    .data$social_care_id) %>%
    # flag which period is last for each client
    dplyr::mutate(latest_sc_id = dplyr::last(.data$period)) %>%
    # flag which extract date is last for each client
    dplyr::mutate(latest_extract_date = dplyr::last(.data$extract_date)) %>%
    dplyr::ungroup() %>%
    # only want records with last period AND last extract date
    # (some periods are submitted more than once)
    dplyr::filter(
      .data$latest_sc_id == .data$period &
        .data$latest_extract_date == .data$extract_date
    ) %>%
    # update these records are now the latest record for each SCID
    # dplyr::mutate(latest_record_flag = 1) %>%
    dplyr::select(-"period",
                  # -"latest_record_flag",
                  -"latest_sc_id",
                  -"latest_extract_date") %>%
    dplyr::arrange(
      .data$sending_location,
      .data$anon_chi,
      .data$financial_year,
      .data$financial_quarter,
      .data$extract_date,
      .data$consistent_quality
    )

  sc_demog_lookup <- sc_demog_ch %>%
    dplyr::select(
      -"postcode_type",
      -"submitted_postcode",
      -"chi_postcode",
      -"postcode_ch_as_home",
      -"submitted_postcode_ch",
      -"chi_postcode_ch"
    ) %>%
    dplyr::distinct() %>%
    # group by sending location and ID, financial year
    dplyr::group_by(
      .data$sending_location,
      .data$anon_chi,
      .data$social_care_id,
      .data$financial_year
    ) %>%
    # arrange so latest submissions are last
    dplyr::arrange(.data$sending_location,
                   .data$social_care_id,
                   .data$anon_chi,
                   .data$financial_quarter,
                   .data$extract_date) %>%
    # summarize to select the last (non NA) submission
    dplyr::summarise(
      gender = dplyr::last(.data$gender),
      dob = dplyr::last(.data$dob),
      postcode = dplyr::last(.data$postcode),
      # postcode_ch_as_home = dplyr::last(.data$postcode_ch_as_home),
      date_of_death = dplyr::last(.data$date_of_death),
      extract_date = dplyr::last(.data$extract_date),
      consistent_quality = dplyr::last(.data$consistent_quality)
    ) %>%
    dplyr::ungroup() %>%
    select_linking_id() %>%
    dplyr::group_by(.data$anon_chi) %>%
    tidyr::fill(
      "gender",
      "dob",
      "date_of_death",
      .direction = "downup"
    ) %>%
    dplyr::ungroup()

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
