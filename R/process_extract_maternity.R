#' Process the maternity extract
#'
#' @description This will read and process the
#' maternity extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_maternity <- function(data, year, write_to_disk = TRUE) {
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
    dplyr::mutate(gpprac = convert_eng_gpprac_to_dummy(.data$gpprac)) %>%
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
      "year",
      "recid",
      "record_keydate1",
      "record_keydate2",
      "chi",
      "gender",
      "dob",
      "gpprac",
      "hbpraccode",
      "postcode",
      "hbrescode",
      "lca",
      "hscp",
      "location",
      "hbtreatcode",
      "stay",
      "yearstay",
      "spec",
      "sigfac",
      "conc",
      "mpat",
      "adtf",
      "admloc",
      tidyselect::starts_with("disch"),
      tidyselect::starts_with("diag"),
      tidyselect::matches("(date)?op[1-4][ab]?"),
      "age",
      "discondition",
      tidyselect::starts_with("cij"),
      "alcohol_adm",
      "submis_adm",
      "falls_adm",
      "selfharm_adm",
      "commhosp",
      "nhshosp",
      "cost_total_net",
      tidyselect::ends_with("_beddays"),
      tidyselect::ends_with("_cost"),
      "uri"
    ) %>%
    dplyr::arrange(.data$chi, .data$record_keydate1)

  if (write_to_disk) {
    # Save as rds file
    outfile %>%
      write_rds(get_source_extract_path(year, "Maternity", check_mode = "write"))
  }

  return(outfile)
}
