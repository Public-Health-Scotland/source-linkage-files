#' Process the mental health extract
#'
#' @description This will read and process the
#' mental health extract, it will return the final data
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
process_extract_mental_health <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning  ---------------------------------------

  mh_clean <- data %>%
    # create year, recid, ipdc variables
    dplyr::mutate(
      year = year,
      recid = "04B",
      ipdc = "I"
    ) %>%
    # deal with dummy / english variables
    convert_eng_gpprac_to_dummy(gpprac) %>%
    # cij_ipdc
    dplyr::mutate(
      cij_ipdc = dplyr::if_else(.data$cij_inpatient == "MH", "I", "NA"),
      cij_ipdc = dplyr::na_if(.data$cij_ipdc, "NA")
    ) %>%
    # cij_admtype recode unknown to 99
    dplyr::mutate(cij_admtype = dplyr::if_else(.data$cij_admtype == "Unknown", "99", .data$cij_admtype)) %>%
    # monthly beddays and costs
    convert_monthly_rows_to_vars(.data$costmonthnum, .data$cost_total_net, .data$yearstay) %>%
    dplyr::mutate(
      # yearstay
      yearstay = rowSums(dplyr::across(tidyselect::ends_with("_beddays"))),
      # cost total net
      cost_total_net = rowSums(dplyr::across(tidyselect::ends_with("_cost"))),
      # total length of stay
      stay = calculate_stay(.data$year, .data$record_keydate1, .data$record_keydate2),
      # SMR type
      smrtype = add_smr_type(recid)
    )


  # Outfile  ---------------------------------------

  outfile <- mh_clean %>%
    # numeric record_keydate
    dplyr::mutate(
      record_keydate1 = lubridate::month(.data$record_keydate1) + 100 * lubridate::month(.data$record_keydate1) + 10000 * lubridate::year(.data$record_keydate1),
      record_keydate2 = lubridate::month(.data$record_keydate2) + 100 * lubridate::month(.data$record_keydate2) + 10000 * lubridate::year(.data$record_keydate2)
    ) %>%
    dplyr::arrange(.data$chi, .data$record_keydate1) %>%
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
      .data$datazone,
      .data$location,
      .data$hbtreatcode,
      .data$stay,
      .data$yearstay,
      .data$ipdc,
      .data$spec,
      .data$sigfac,
      .data$conc,
      .data$mpat,
      .data$cat,
      .data$tadm,
      .data$adtf,
      .data$admloc,
      .data$disch,
      .data$dischto,
      .data$dischloc,
      tidyselect::starts_with("diag"),
      .data$age,
      tidyselect::starts_with("cij_"),
      tidyselect::ends_with("_adm"),
      .data$commhosp,
      .data$cost_total_net,
      .data$stadm,
      tidyselect::starts_with("adcon"),
      tidyselect::ends_with("_beddays"),
      tidyselect::ends_with("_cost"),
      .data$uri
    )

  outfile %>%
    # Save as rds file
    write_rds(get_source_extract_path(year, "MH", check_mode = "write"))

  return(outfile)
}
