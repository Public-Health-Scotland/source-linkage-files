#' Process the social care demographic lookup
#'
#' @description This will read and process the
#' social care demographic lookup, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_sc_demographics <- function(data, write_to_disk = TRUE) {
  ## Deal with postcodes---------------------------------------

  # UK postcode regex - see https://ideal-postcodes.co.uk/guides/postcode-validation
  uk_pc_regexp <- "^[a-z]{1,2}\\d[a-z\\d]?\\s*\\d[a-z]{2}$"

  dummy_postcodes <- c("NK1 0AA", "NF1 1AB")
  non_existant_postcodes <- c("PR2 5AL", "M16 0GS", "DY103DJ")

  ## postcode type ##
  valid_spd_postcodes <- readr::read_rds(get_spd_path()) %>%
    dplyr::pull(.data$pc7)


  # Data Cleaning ---------------------------------------

  sc_demog <- data %>%
    dplyr::mutate(
      # use chi if upi is NA
      upi = dplyr::coalesce(.data$upi, .data$chi_upi),
      # check gender code - replace code 99 with 9
      submitted_gender = replace(.data$submitted_gender, .data$submitted_gender == 99, 9)
    ) %>%
    dplyr::mutate(
      # use chi gender if avaliable
      gender = dplyr::if_else(is.na(.data$chi_gender_code) | .data$chi_gender_code == 9, .data$submitted_gender, .data$chi_gender_code),
      # use chi dob if avaliable
      dob = dplyr::coalesce(.data$chi_date_of_birth, .data$submitted_date_of_birth)
    ) %>%
    # format postcodes using `phsmethods`
    dplyr::mutate(dplyr::across(tidyselect::contains("postcode"), ~ phsmethods::format_postcode(.x, format = "pc7")))

  # count number of na postcodes
  na_postcodes <-
    sc_demog %>%
    dplyr::count(dplyr::across(tidyselect::contains("postcode"), ~ is.na(.x)))

  sc_demog <- sc_demog %>%
    # remove dummy postcodes invalid postcodes missed by regex check
    dplyr::mutate(dplyr::across(tidyselect::ends_with("_postcode"), ~ dplyr::na_if(.x, .x %in% c(dummy_postcodes, non_existant_postcodes)))) %>%
    # comparing with regex UK postcode
    dplyr::mutate(dplyr::across(tidyselect::ends_with("_postcode"), ~ dplyr::na_if(.x, !stringr::str_detect(.x, uk_pc_regexp)))) %>%
    dplyr::select(
      .data$latest_record_flag, .data$extract_date, .data$sending_location, .data$social_care_id, .data$upi, .data$gender,
      .data$dob, .data$submitted_postcode, .data$chi_postcode
    ) %>%
    # check if submitted_postcode matches with postcode lookup
    dplyr::mutate(valid_pc = dplyr::if_else(.data$submitted_postcode %in% valid_spd_postcodes, 1, 0)) %>%
    # use submitted_postcode if valid, otherwise use chi_postcode
    dplyr::mutate(postcode = dplyr::case_when(
      (!is.na(.data$submitted_postcode) & .data$valid_pc == 1) ~ .data$submitted_postcode,
      (is.na(.data$submitted_postcode) & .data$valid_pc == 0) ~ .data$chi_postcode
    )) %>%
    dplyr::mutate(postcode_type = dplyr::case_when(
      (!is.na(.data$submitted_postcode) & .data$valid_pc == 1) ~ "submitted",
      (is.na(.data$submitted_postcode) & .data$valid_pc == 0) ~ "chi",
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
    # arrange so lastest submissions are last
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
      write_rds(get_sc_demog_lookup_path(check_mode = "write"))
  }

  return(outfile)
}
