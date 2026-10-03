#' Process the (year specific) Home Care extract
#'
#' @description This will read and process the
#' (year specific) Home Care extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The full processed data which will be selected from to create
#' the year specific data.
#' @param year The year to process, in FY format.
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_home_care <- function(data,
                                      year,
                                      write_to_disk = TRUE,
                                      BYOC_MODE = FALSE) {
  log_slf_event(stage = "process", status = "start", type = "hc", year = year)

  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year, format = "fyyear")

  # Check that we have data for this year
  if (!check_year_valid(year, "hc")) {
    # If not return an empty tibble
    return(tibble::tibble())
  }

  # Selections for financial year ------------------------------------

  hc_data <- data %>%
    # Select episodes for FY
    dplyr::filter(is_date_in_fyyear(
      year,
      .data[["record_keydate1"]],
      .data[["record_keydate2"]]
    )) %>%
    # Remove any episodes where the latest submission was before the current year
    dplyr::filter(
      substr(.data$sc_latest_submission, 1L, 4L) >= convert_fyyear_to_year(year)
    ) %>%
    dplyr::mutate(year = year)

  # Home Care Hours ---------------------------------------

  hc_hours <- hc_data %>%
    # Rename hours variables
    dplyr::rename(
      hc_hours_q1 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q1"),
      hc_hours_q2 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q2"),
      hc_hours_q3 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q3"),
      hc_hours_q4 = paste0("hc_hours_", convert_fyyear_to_year(year), "Q4")
    ) %>%
    # Remove hours variables not from current year
    dplyr::select(-(tidyselect::contains("hc_hours_2"))) %>%
    # Create annual hours variable
    dplyr::mutate(hc_hours_annual = rowSums(
      dplyr::pick(tidyselect::contains("hc_hours_q")),
      na.rm = TRUE
    ))

  # Home Care Costs ---------------------------------------

  hc_costs <- hc_hours %>%
    # Rename costs variables
    dplyr::rename(
      hc_cost_q1 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q1"),
      hc_cost_q2 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q2"),
      hc_cost_q3 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q3"),
      hc_cost_q4 = paste0("hc_cost_", convert_fyyear_to_year(year), "Q4")
    ) %>%
    # Remove cost variables not from current year
    dplyr::select(-(tidyselect::contains("hc_cost_2"))) %>%
    # Create cost total net
    dplyr::mutate(
      cost_total_net = rowSums(
        dplyr::pick(tidyselect::contains("hc_cost_q")),
        na.rm = TRUE
      )
    )

  hc_processed <- hc_costs %>%
    dplyr::select(
      "run_id",
      "run_date_time",
      "year",
      "recid",
      "smrtype",
      "anon_chi",
      "social_care_id",
      "person_id",
      "linking_id",
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
      data = hc_processed,
      path = get_source_extract_path(
        year = year,
        type = "hc",
        check_mode = "write",
        BYOC_MODE = BYOC_MODE
      ),
      group_id = 3356, # sourcedev owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "hc", year = year)

  return(hc_processed)
}
