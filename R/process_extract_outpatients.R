#' Process the Outpatients extract
#'
#' @description This will read and process the
#' outpatients extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param year The year to process, in FY format.
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_outpatients <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning--------------------------------------------

  outpatients_clean <- data %>%
    # Set year variable
    dplyr::mutate(
      year = year,
      # Set recid variable
      recid = "00B",
      # Set smrtype variable
      smrtype = add_smr_type(.data$recid)
    ) %>%
    # Recode GP Practice into a 5 digit number
    # assume that if it starts with a letter it's an English practice and so recode to 99995
    convert_eng_gpprac_to_dummy(gpprac) %>%
    # compute record key date2
    dplyr::mutate(record_keydate2 = .data$record_keydate1) %>%
    # Allocate the costs to the correct month
    create_day_episode_costs(.data$record_keydate1, .data$cost_total_net) %>%
    # sort by chi record_keydate1
    dplyr::arrange(.data$chi, .data$record_keydate1)

  # Factors ---------------------------------------
  outpatients_clean <- outpatients_clean %>%
    dplyr::mutate(
      reftype = factor(.data$reftype,
        levels = c(1:3)
      ),
      clinic_type = factor(.data$clinic_type,
        levels = c(1:4)
      )
    )


  ## save outfile ---------------------------------------

  outfile <-
    outpatients_clean %>%
    dplyr::select(
      .data$year,
      .data$recid,
      .data$record_keydate1,
      .data$record_keydate2,
      .data$smrtype,
      .data$chi,
      .data$gender,
      .data$dob,
      .data$gpprac,
      .data$hbpraccode,
      .data$postcode,
      .data$hbrescode,
      .data$lca,
      .data$location,
      .data$hbtreatcode,
      tidyselect::contains("op"),
      .data$spec,
      .data$sigfac,
      .data$conc,
      .data$cat,
      .data$age,
      .data$refsource,
      .data$reftype,
      .data$attendance_status,
      .data$clinic_type,
      tidyselect::ends_with("_adm"),
      .data$commhosp,
      .data$nhshosp,
      .data$cost_total_net,
      tidyselect::ends_with("_cost"),
      .data$uri
    )

  if (write_to_disk) {
    # Save as rds file
    outfile %>%
      write_rds(get_source_extract_path(year, "Outpatients", check_mode = "write"))
  }

  return(outfile)
}
