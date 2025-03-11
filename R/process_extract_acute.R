#' Process the Acute extract
#'
#' @description This will read and process the
#' acute extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param acute_cup_path path to acute_cup data
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_acute <- function(data,
                                  year,
                                  acute_cup_path = get_boxi_extract_path(year, "acute_cup"),
                                  write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

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
    # Reset community hospital flag as an integer
    dplyr::mutate(
      commhosp = dplyr::if_else(.data$commhosp == "Y", 1L, 0L),
      commhosp = as.integer(.data$commhosp)
    ) %>%
    # Recode GP practice into 5 digit number
    # We assume that if it starts with a letter it's an English practice and so recode to 99995.
    dplyr::mutate(gpprac = convert_eng_gpprac_to_dummy(.data$gpprac)) %>%
    # Calculate the total length of stay (for the entire episode, not just within the financial year).
    dplyr::mutate(
      stay = calculate_stay(year, .data$record_keydate1, .data$record_keydate2),
      # create and populate SMRType
      smrtype = add_smrtype(recid = .data$recid, ipdc = .data$ipdc)
    ) %>%
    # Apply new costs for C3 specialty, these are taken from the 2017/18 file
    fix_c3_costs(year) %>%
    # initialise monthly cost/beddays variables in a separate data frame for matching
    convert_monthly_rows_to_vars(.data$costmonthnum, .data$cost_total_net, .data$yearstay) %>%
    # add yearstay and cost_total_net variables
    dplyr::mutate(
      yearstay = rowSums(dplyr::pick(tidyselect::ends_with("_beddays"))),
      cost_total_net = rowSums(dplyr::pick(tidyselect::ends_with("_cost")))
    ) %>%
    # Add oldtadm as a factor with labels
    dplyr::mutate(oldtadm = factor(.data$oldtadm,
      levels = 0L:8L
    )) %>%
    dplyr::mutate(
      unique_row_num = dplyr::row_number()
    )

  acute_cup <- read_file(
    path = acute_cup_path,
    col_type = readr::cols(
      "anon_chi" = readr::col_character(),
      "Acute Admission Date" = readr::col_date(format = "%Y/%m/%d %T"),
      "Acute Discharge Date" = readr::col_date(format = "%Y/%m/%d %T"),
      "Acute Admission Type Code" = readr::col_character(),
      "Acute Discharge Type Code" = readr::col_character(),
      "Case Reference Number [C]" = readr::col_character(),
      "CUP Marker" = readr::col_integer(),
      "CUP Pathway Name" = readr::col_character()
    )
  ) %>%
    dplyr::select(
      anon_chi = "anon_chi",
      case_reference_number = "Case Reference Number [C]",
      record_keydate1 = "Acute Admission Date",
      record_keydate2 = "Acute Discharge Date",
      tadm = "Acute Admission Type Code",
      disch = "Acute Discharge Type Code",
      cup_marker = "CUP Marker",
      cup_pathway = "CUP Pathway Name"
    ) %>%
    dplyr::distinct()

  acute_clean <- acute_clean %>%
    dplyr::left_join(acute_cup,
      by = c(
        "record_keydate1",
        "record_keydate2",
        "case_reference_number",
        "anon_chi",
        "tadm",
        "disch"
      )
    )

  acute_processed <- acute_clean %>%
    dplyr::select(
      "year",
      "recid",
      "record_keydate1",
      "record_keydate2",
      "smrtype",
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
      "yearstay",
      "stay",
      "ipdc",
      "spec",
      "sigfac",
      "conc",
      "mpat",
      "cat",
      "tadm",
      "adtf",
      "admloc",
      "oldtadm",
      tidyselect::starts_with("disch"),
      tidyselect::starts_with("diag"),
      tidyselect::matches("(date)?op[1-4][ab]?"),
      "smr01_cis_marker",
      "age",
      tidyselect::starts_with("cij"),
      "alcohol_adm",
      "submis_adm",
      "falls_adm",
      "selfharm_adm",
      "commhosp",
      "cost_total_net",
      tidyselect::ends_with("_beddays"),
      tidyselect::ends_with("_cost"),
      "uri",
      "cup_marker",
      "cup_pathway"
    ) %>%
    dplyr::arrange(.data$anon_chi, .data$record_keydate1)

  if (write_to_disk) {
    write_file(
      acute_processed,
      get_source_extract_path(year, "acute", check_mode = "write")
    )
  }

  return(acute_processed)
}
