#' Process the maternity extract
#'
#' @description This will read and process the
#' maternity extract, it will return the final data
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
process_extract_maternity <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning  ---------------------------------------

  maternity_clean <- data %>%
    # Create new columns for recid and gender
    dplyr::mutate(
      year = year,
      recid = "02B",
      gender = 2
    ) %>%
    # Set IDPC marker for the cij
    dplyr::mutate(cij_ipdc = dplyr::case_when(
      .data$cij_ipdc == "IP" ~ "I",
      .data$cij_ipdc == "DC" ~ "D"
    )) %>%
    # Recode GP practice into 5 digit number
    # We assume that if it starts with a letter it's an English practice and so recode to 99995.
    convert_eng_gpprac_to_dummy(gpprac) %>%
    # Calculate the total length of stay (for the entire episode, not just within the financial year).
    dplyr::mutate(
      stay = calculate_stay(year, .data$record_keydate1, .data$record_keydate2)
    ) %>%
    # Calculate beddays
    create_monthly_beddays(year, .data$record_keydate1, .data$record_keydate2) %>%
    # Calculate costs
    create_monthly_costs() %>%
    # Add discondition as a factor
    dplyr::mutate(
      discondition = factor(.data$discondition,
        levels = c(1:5, 8)
      ),
      smrtype = add_smr_type(.data$recid, .data$mpat)
    )


  # Save outfile------------------------------------------------

  outfile <- maternity_clean %>%
    dplyr::select(
      .data$year,
      .data$recid,
      .data$record_keydate1,
      .data$record_keydate2,
      .data$chi,
      .data$gender,
      .data$dob,
      .data$gpprac,
      .data$hbpraccode,
      .data$postcode,
      .data$hbrescode,
      .data$lca,
      .data$hscp,
      .data$location,
      .data$hbtreatcode,
      .data$stay,
      .data$yearstay,
      .data$spec,
      .data$sigfac,
      .data$conc,
      .data$mpat,
      .data$adtf,
      .data$admloc,
      tidyselect::starts_with("disch"),
      tidyselect::starts_with("diag"),
      tidyselect::matches("(date)?op[1-4][ab]?"),
      .data$age,
      .data$discondition,
      tidyselect::starts_with("cij"),
      .data$alcohol_adm,
      .data$submis_adm,
      .data$falls_adm,
      .data$selfharm_adm,
      .data$commhosp,
      .data$nhshosp,
      .data$cost_total_net,
      tidyselect::ends_with("_beddays"),
      tidyselect::ends_with("_cost"),
      .data$uri
    ) %>%
    dplyr::arrange(.data$chi, .data$record_keydate1)

  if (write_to_disk) {
  # Save as rds file
  outfile %>%
    write_rds(get_source_extract_path(year, "Maternity", check_mode = "write"))
  }

  return(outfile)
}
