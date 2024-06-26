#' Process the maternity extract
#'
#' @description This will read and process the
#' maternity extract, it will return the final data
#' and (optionally) write it to disk.
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
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning  ---------------------------------------

  maternity_clean <- data %>%
    # Create new columns for recid and gender
    dplyr::mutate(
      year = year,
      recid = "02B",
      gender = 2L
    ) %>%
    # Set IDPC marker for the cij
    dplyr::mutate(cij_ipdc = dplyr::case_when(
      .data$cij_ipdc == "IP" ~ "I",
      .data$cij_ipdc == "DC" ~ "D"
    )) %>%
    # Recode GP practice into 5 digit number
    # We assume that if it starts with a letter it's an English practice and so recode to 99995.
    dplyr::mutate(
      gpprac = convert_eng_gpprac_to_dummy(.data$gpprac)
    ) %>%
    # Calculate the total length of stay (for the entire episode, not just within the financial year).
    dplyr::mutate(
      stay = calculate_stay(year, .data$record_keydate1, .data$record_keydate2)
    ) %>%
    # Calculate beddays
    create_monthly_beddays(
      year,
      .data$record_keydate1,
      .data$record_keydate2
    ) %>%
    # Calculate costs
    create_monthly_costs() %>%
    # Add discondition as a factor
    dplyr::mutate(
      discondition = factor(.data$discondition,
        levels = c(1L:5L, 8L)
      ),
      smrtype = add_smrtype(.data$recid, .data$mpat),
      ipdc = dplyr::case_match(
        .data$smrtype,
        "Matern-IP" ~ "I",
        "Matern-DC" ~ "D"
      )
    )

  maternity_processed <- maternity_clean %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
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
      "uri",
      "ipdc"
    ) %>%
    dplyr::arrange(.data$chi, .data$record_keydate1) %>%
    slfhelper::get_anon_chi()

  if (write_to_disk) {
    write_file(
      maternity_processed,
      get_source_extract_path(year, "maternity", check_mode = "write")
    )
  }

  return(maternity_processed)
}
