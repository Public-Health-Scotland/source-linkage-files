#' Process the (year specific) Home Care extract
#'
#' @description This will read and process the
#' (year specific) Home Care extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @inheritParams process_extract_care_home
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_home_care <- function(
    data,
    year,
    write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Check that we have data for this year
  if (!check_year_valid(year, "hc")) {
    # If not return an empty tibble
    return(tibble::tibble())
  }

  # Selections for financial year------------------------------------

  hc_data <- data %>%
    # select episodes for FY
    dplyr::filter(is_date_in_fyyear(
      year,
      .data[["record_keydate1"]],
      .data[["record_keydate2"]]
    )) %>%
    # remove any episodes where the latest submission was before the current year
    dplyr::filter(
      substr(.data$sc_latest_submission, 1L, 4L) >= convert_fyyear_to_year(year)
    ) %>%
    dplyr::mutate(year = year)

  # Home Care Hours ---------------------------------------

  hc_hours <- hc_data %>%
    # rename hours variables
    dplyr::rename(
      hc_hours_q1 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q1"),
      hc_hours_q2 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q2"),
      hc_hours_q3 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q3"),
      hc_hours_q4 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q4")
    ) %>%
    # remove hours variables not from current year
    dplyr::select(-(tidyselect::contains("hc_hours_2"))) %>%
    # create annual hours variable
    dplyr::mutate(hc_hours_annual = rowSums(
      dplyr::pick(tidyselect::contains("hc_hours_q")),
      na.rm = TRUE
    ))


  # Home Care Costs ---------------------------------------

  hc_costs <- hc_hours %>%
    # rename costs variables
    dplyr::rename(
      hc_cost_q1 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q1"),
      hc_cost_q2 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q2"),
      hc_cost_q3 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q3"),
      hc_cost_q4 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q4")
    ) %>%
    # remove cost variables not from current year
    dplyr::select(-(tidyselect::contains("hc_cost_2"))) %>%
    # create cost total net
    dplyr::mutate(
      cost_total_net = rowSums(
        dplyr::pick(tidyselect::contains("hc_cost_q")),
        na.rm = TRUE
      )
    )

  hc_processed <- hc_costs %>%
    dplyr::select(
      "year",
      "recid",
      "smrtype",
      "anon_chi",
      "social_care_id",
      "person_id",
      "dob",
      "gender",
      "postcode",
      "sc_send_lca",
      "record_keydate1",
      "record_keydate2",
      tidyselect::starts_with("hc_hours_"),
      tidyselect::starts_with("hc_cost_"),
      "cost_total_net",
      "hc_provider",
      "hc_reablement"
    )

  if (write_to_disk) {
    write_file(
      hc_processed,
      get_source_extract_path(year, type = "hc", check_mode = "write"),
      group_id = 3356 # sourcedev owner
    )
  }

  return(hc_processed)
}
