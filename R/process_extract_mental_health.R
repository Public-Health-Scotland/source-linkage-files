#' Process the mental health extract
#'
#' @description This will read and process the
#' mental health extract, it will return the final data
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
process_extract_mental_health <- function(data, year, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

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
    dplyr::mutate(gpprac = convert_eng_gpprac_to_dummy(.data$gpprac)) %>%
    # cij_ipdc
    dplyr::mutate(
      cij_ipdc = dplyr::na_if(
        dplyr::if_else(.data$cij_inpatient == "MH", "I", "NA"),
        "NA"
      )
    ) %>%
    dplyr::select(-.data$cij_inpatient) %>%
    # cij_admtype recode unknown to 99
    dplyr::mutate(
      cij_admtype = dplyr::if_else(
        .data$cij_admtype == "Unknown",
        "99",
        .data$cij_admtype
      )
    ) %>%
    # monthly beddays and costs
    convert_monthly_rows_to_vars(
      .data$costmonthnum,
      .data$cost_total_net,
      .data$yearstay
    ) %>%
    dplyr::mutate(
      # yearstay
      yearstay = rowSums(dplyr::pick(tidyselect::ends_with("_beddays"))),
      # cost total net
      cost_total_net = rowSums(dplyr::pick(tidyselect::ends_with("_cost"))),
      # total length of stay
      stay = calculate_stay(
        .data$year,
        .data$record_keydate1,
        .data$record_keydate2
      ),
      # SMR type
      smrtype = add_smrtype(.data$recid)
    ) %>%
    # Reset community hospital flag as an integer
    dplyr::mutate(
      commhosp = dplyr::if_else(.data$commhosp == "Y", 1L, 0L),
      commhosp = as.integer(commhosp)
    )

  mh_processed <- mh_clean %>%
    dplyr::arrange(.data$anon_chi, .data$record_keydate1) %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
      "record_keydate1",
      "record_keydate2",
      "anon_chi",
      "gender",
      "dob",
      "gpprac",
      "hbpraccode",
      "postcode",
      "hbrescode",
      "lca",
      "hscp",
      "datazone2011",
      "location",
      "hbtreatcode",
      "stay",
      "yearstay",
      "ipdc",
      "spec",
      "sigfac",
      "conc",
      "mpat",
      "cat",
      "tadm",
      "adtf",
      "admloc",
      "disch",
      "dischto",
      "dischloc",
      tidyselect::starts_with("diag"),
      "age",
      tidyselect::starts_with("cij_"),
      tidyselect::ends_with("_adm"),
      "commhosp",
      "cost_total_net",
      "stadm",
      tidyselect::starts_with("adcon"),
      tidyselect::ends_with("_beddays"),
      tidyselect::ends_with("_cost"),
      "uri"
    )

  if (write_to_disk) {
    write_file(
      mh_processed,
      get_source_extract_path(year, "mh", check_mode = "write")
    )
  }

  return(mh_processed)
}
