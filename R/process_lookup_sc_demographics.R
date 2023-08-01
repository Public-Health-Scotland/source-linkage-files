#' Process the social care demographic lookup
#'
#' @description This will read and process the
#' social care demographic lookup, it will return the final data
#' but also write this out as an rds.
#'
#' @param data The extract to process.
#' @param spd_path Path to the Scottish Postcode Directory.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_sc_demographics <- function(data, spd_path = get_spd_path(), write_to_disk = TRUE) {
  # Deal with postcodes ---------------------------------------

  # UK postcode regex - see https://ideal-postcodes.co.uk/guides/postcode-validation
  uk_pc_regexp <- "^[A-Z]{1,2}[0-9][A-Z0-9]?\\s*[0-9][A-Z]{2}$"

  dummy_postcodes <- c("NK1 0AA", "NF1 1AB")
  non_existant_postcodes <- c("PR2 5AL", "M16 0GS", "DY103DJ")

  valid_spd_postcodes <- read_file(spd_path, col_select = "pc7") %>%
    dplyr::pull(.data$pc7)


  # Data Cleaning ---------------------------------------

  sc_demog <- data %>%
    dplyr::mutate(
      # use chi if upi is NA
      upi = dplyr::coalesce(.data$upi, .data$chi_upi),
      # check gender code - replace code 99 with 9
      submitted_gender = replace(.data$submitted_gender, .data$submitted_gender == 99L, 9L)
    ) %>%
    dplyr::mutate(
      # use CHI sex if available
      gender = dplyr::if_else(
        is.na(.data$chi_gender_code) | .data$chi_gender_code == 9L,
        .data$submitted_gender,
        .data$chi_gender_code
      ),
      # Use CHI DoB if available
      dob = dplyr::coalesce(.data$chi_date_of_birth, .data$submitted_date_of_birth)
    ) %>%
    # format postcodes using `phsmethods`
    dplyr::mutate(dplyr::across(
      tidyselect::contains("postcode"),
      ~ phsmethods::format_postcode(.x, format = "pc7")
    ))

  # count number of na postcodes
  na_postcodes <-
    sc_demog %>%
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
      "upi",
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
  na_replaced_postcodes <-
    sc_demog %>%
    dplyr::count(dplyr::across(tidyselect::ends_with("_postcode"), ~ is.na(.x)))

  na_replaced_postcodes
  na_postcodes


  ## save outfile ---------------------------------------
  outfile <-
    sc_demog %>%
    # group by sending location and ID
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    # arrange so latest submissions are last
    dplyr::arrange(
      .data$sending_location,
      .data$social_care_id,
      .data$latest_record_flag,
      .data$extract_date
    ) %>%
    # summarise to select the last (non NA) submission
    dplyr::summarise(
      chi = dplyr::last(.data$upi),
      gender = dplyr::last(.data$gender),
      dob = dplyr::last(.data$dob),
      postcode = dplyr::last(.data$postcode)
    ) %>%
    dplyr::ungroup()


  ## save file ##

  if (write_to_disk) {
    # Save .rds file
    outfile %>%
      write_file(get_sc_demog_lookup_path(check_mode = "write"))
  }

  return(outfile)
}
