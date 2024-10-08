#' Match on BOXI NRS death dates to process activity after death flag
#'
#' @description Match on CHI number where available in the episode file, and add date of death from the BOXI NRS lookup.
#' Create new activity after death flag
#'
#' @param data episode files
#' @param year financial year, e.g. '1920'
#' @param deaths_data The death data for the year
#'
#' @return data flagged if activity after death
add_activity_after_death_flag <- function(
    data,
    year,
    deaths_data = read_file(get_combined_slf_deaths_lookup_path()) %>%
      slfhelper::get_chi()) {
  cli::cli_alert_info("Add activity after death flag function started at {Sys.time()}")

  # to skip warnings no visible binding for global variable ‘.’
  . <- NULL

  death_joined <- data %>%
    dplyr::select(.data$year, .data$chi, .data$record_keydate1, .data$record_keydate2, .data$death_date, .data$deceased) %>%
    dplyr::filter(!is.na(.data$chi) | .data$chi != "") %>%
    dplyr::left_join(
      deaths_data,
      by = "chi",
      suffix = c("", "_boxi")
    ) %>%
    dplyr::filter(.data$deceased == TRUE) %>%
    dplyr::distinct()


  # Check and print error message for records which already have a death_date in the episode file, but this doesn't match the BOXI death date
  check_death_date_match <- death_joined %>%
    dplyr::filter(.data$death_date != .data$death_date_boxi)

  if (nrow(check_death_date_match) != 0) {
    warning("There were records in the episode file which already have a death_date, but does not match the BOXI NRS death date.")
  }


  # Check and print error message for records which have a record_keydate1 after their BOXI death date
  check_keydate1_death_date <- death_joined %>%
    dplyr::filter(.data$record_keydate1 > .data$death_date_boxi)

  if (nrow(check_death_date_match) != 0) {
    warning("There were records in the episode file which have a record_keydate1 after the BOXI NRS death date.")
  }


  flag_data <- death_joined %>%
    dplyr::mutate(
      flag_keydate1 = dplyr::if_else(.data$record_keydate1 > .data$death_date_boxi, 1, 0),
      flag_keydate2 = dplyr::if_else(.data$record_keydate2 > .data$death_date_boxi, 1, 0),

      # Next flag records with 'ongoing' activity after date of death (available from BOXI) if keydate2 is missing and the death date occurs in
      # in the current or a previous financial year.
      flag_keydate2_missing = dplyr::if_else(((is.na(.data$record_keydate2) | .data$record_keydate2 == "") & (.data$death_date_boxi <= paste0("20", substr(.data$year, 3, 4), "-03-31"))), 1, 0),

      # Also flag records without a death_date in the episode file, but the BOXI death date occurs in the current or a previous financial year.
      flag_deathdate_missing = dplyr::if_else(((is.na(.data$death_date) | .data$death_date == "") & (.data$death_date_boxi <= paste0("20", substr(.data$year, 3, 4), "-03-31"))), 1, 0)
    ) %>%
    # These should be flagged by one of the two lines of code above, but in these cases, we will also fill in the blank death date if appropriate

    # Search all variables beginning with "flag_" for value "1" and create new variable to flag cases where 1 is present
    # Multiplying by 1 changes flag from true/false to 1/0
    dplyr::mutate(activity_after_death = purrr::pmap_dbl(
      dplyr::select(., tidyselect::contains("flag_")),
      ~ any(grepl("^1$", c(...)),
        na.rm = TRUE
      ) * 1
    ))


  # Fill in date of death if missing in the episode file but available in BOXI lookup, due to historic dates of death not being carried
  # over from previous financial years
  flag_data <- flag_data %>%
    dplyr::filter(.data$activity_after_death == 1) %>%
    # Remove temporary flag variables used to create activity after death flag and fill in missing death_date
    dplyr::select(.data$year, .data$chi, .data$record_keydate1, .data$record_keydate2, .data$activity_after_death, .data$death_date_boxi) %>%
    dplyr::distinct()

  # Match activity after death flag back to episode file
  final_data <- data %>%
    dplyr::left_join(
      flag_data,
      # TODO: this join_by is not 100% accurate. Consider use ep_file_row_id to join
      by = c("year", "chi", "record_keydate1", "record_keydate2"),
      na_matches = "never"
    ) %>%
    dplyr::mutate(death_date = lubridate::as_date(ifelse(is.na(death_date) & !(is.na(death_date_boxi)),
      death_date_boxi, death_date
    ))) %>%
    dplyr::select(-death_date_boxi) %>%
    dplyr::distinct()



  return(final_data)
}


#' Create and read SLF Deaths lookup from processed BOXI NRS deaths extracts
#'
#' @description The BOXI NRS deaths extract lookup should be created after the extract files for all years have been processed,
# but before an episode file has been produced. Therefore, all BOXI NRS years should be run before running episode files.
#'
#' @param ... additional arguments passed to [get_slf_deaths_lookup_path()]
#' @param update the update month (defaults to use [latest_update()])
#'
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#'
#'
#'
# Read data------------------------------------------------

process_combined_deaths_lookup <- function(update = latest_update(),
                                           write_to_disk = TRUE, ...) {
  dir_folder <- "/conf/hscdiip/SLF_Extracts/Deaths"
  file_names <- list.files(dir_folder,
    pattern = "^anon-slf_deaths_lookup_.*parquet",
    full.names = TRUE
  )

  # read all year specific deaths lookups and bind them together
  all_boxi_deaths <- lapply(file_names, arrow::read_parquet) %>%
    data.table::rbindlist() %>%
    # convert to chi for processing
    slfhelper::get_chi() %>%
    # Remove rows with missing or blank CHI number - could also use na.omit?
    # na.omit(all_boxi_deaths)
    dplyr::filter(!is.na(.data$chi) | .data$chi != "")

  # Check all CHI numbers are valid
  chi_check <- all_boxi_deaths %>%
    dplyr::pull(.data$chi) %>%
    phsmethods::chi_check()

  if (!all(chi_check %in% c("Valid CHI", "Missing (Blank)", "Missing (NA)"))) {
    # There are some Missing (NA) values in the extracts, but I have excluded them above as they cannot be matched to episode file
    stop("There were bad CHI numbers in the BOXI NRS file")
  }

  # Check and print error message for chi numbers with more than one death date
  duplicates <- all_boxi_deaths %>%
    janitor::get_dupes(.data$chi)

  if (nrow(duplicates) != 0) {
    # There are some Missing (NA) values in the extracts, but I have excluded them above as they cannot be matched to episode file
    warning("There were duplicate death dates in the BOXI NRS file.")
  }


  # We decided to include duplicates as unable to determine which is correct date (unless IT can tell us, however, they don't seem to know
  # the process well enough), and overall impact will be negligible
  # Get anon_chi and use this to match onto episode file later
  all_boxi_deaths <- all_boxi_deaths %>%
    slfhelper::get_anon_chi()

  # Save out duplicates for further investigation if needed (as anon_chi)
  if (!missing(duplicates)) {
    write_file(
      duplicates,
      fs::path(get_slf_dir(), "Deaths",
        file_name = stringr::str_glue("slf_deaths_duplicates_{update}.parquet")
      )
    )
  }

  # Maybe save as its own function
  # Write the all BOXI NRS deaths lookup file to disk, so this can be used to populate activity after death flag in each episode file
  if (write_to_disk) {
    write_file(
      all_boxi_deaths,
      get_combined_slf_deaths_lookup_path()
    )
  }

  return(all_boxi_deaths)
}
