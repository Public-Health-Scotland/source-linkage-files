#' Process the Acute extract
#'
#' @description This will read and process the
#' acute extract, it will return the final data
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
process_extract_acute <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning  ---------------------------------------


  acute_clean <- data %>%
    # Set year variable
    dplyr::mutate(
      year = year,
      # Set recid as 01B and flag GLS records
      recid = dplyr::if_else(.data$GLS_record == "Y", "GLS", "01B"),
      # Set IDPC marker for the episode
      ipdc = dplyr::case_when(
        .data$ipdc == "IP" ~ "I",
        .data$ipdc == "DC" ~ "D"
      ),
      # Set IDPC marker for the cij
      cij_ipdc = dplyr::case_when(
        .data$cij_ipdc == "IP" ~ "I",
        .data$cij_ipdc == "DC" ~ "D"
      )
    ) %>%
    # Recode GP practice into 5 digit number
    # We assume that if it starts with a letter it's an English practice and so recode to 99995.
    convert_eng_gpprac_to_dummy(gpprac) %>%
    # Calculate the total length of stay (for the entire episode, not just within the financial year).
    dplyr::mutate(
      stay = calculate_stay(year, .data$record_keydate1, .data$record_keydate2),
      # create and populate SMRType
      smrtype = add_smr_type(recid = .data$recid, ipdc = .data$ipdc)
    ) %>%
    # Apply new costs for C3 specialty, these are taken from the 2017/18 file
    fix_c3_costs(year) %>%
    # initialise monthly cost/beddays variables in a separate data frame for matching
    convert_monthly_rows_to_vars(.data$costmonthnum, .data$cost_total_net, .data$yearstay) %>%
    # add yearstay and cost_total_net variables
    dplyr::mutate(
      yearstay = rowSums(dplyr::across(tidyselect::ends_with("_beddays"))),
      cost_total_net = rowSums(dplyr::across(tidyselect::ends_with("_cost")))
    ) %>%
    # Add oldtadm as a factor with labels
    dplyr::mutate(oldtadm = factor(.data$oldtadm,
      levels = c(0:8)
    ))


  ## save outfile ---------------------------------------
  outfile <- acute_clean %>%
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
      .data$HSCP,
      .data$DataZone,
      .data$location,
      .data$hbtreatcode,
      .data$yearstay,
      .data$stay,
      .data$ipdc,
      .data$spec,
      .data$sigfac,
      .data$conc,
      .data$mpat,
      .data$cat,
      .data$tadm,
      .data$adtf,
      .data$admloc,
      .data$oldtadm,
      tidyselect::starts_with("disch"),
      tidyselect::starts_with("diag"),
      tidyselect::matches("(date)?op[1-4][ab]?"),
      .data$smr01_cis_marker,
      .data$age,
      tidyselect::starts_with("cij"),
      .data$alcohol_adm,
      .data$submis_adm,
      .data$falls_adm,
      .data$selfharm_adm,
      .data$commhosp,
      .data$cost_total_net,
      tidyselect::ends_with("_beddays"),
      tidyselect::ends_with("_cost"),
      .data$uri
    ) %>%
    dplyr::arrange(.data$chi, .data$record_keydate1)

  if (write_to_disk) {
    # Save as rds file
    outfile %>%
      write_rds(get_source_extract_path(year, "Acute", check_mode = "write"))
  }
}
