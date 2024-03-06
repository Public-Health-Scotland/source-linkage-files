#' Process Episode file tests
#'
#' @description Takes the processed episode file and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_episode_file <- function(data, year) {
  data <- data %>%
    dplyr::select(
      "year",
      "anon_chi",
      "gender",
      "postcode",
      "hbtreatcode",
      "hscp2018",
      "dob",
      "recid",
      "yearstay",
      "record_keydate1",
      "record_keydate2",
      dplyr::contains(c("beddays", "cost", "cij"))
    )

  old_data <- get_existing_data_for_tests(data, anon_chi = TRUE)

  comparison <- produce_test_comparison(
    old_data = produce_episode_file_tests(old_data),
    new_data = produce_episode_file_tests(data),
    recid = TRUE
  ) %>%
    dplyr::arrange(.data[["recid"]]) %>%
    write_tests_xlsx(sheet_name = "ep_file", year, workbook_name = "ep_file")

  return(comparison)
}

#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by most
#' of the extracts.
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbtreatcode`
#' using [create_hb_test_flags()], a total cost for each `hbtreatcode` using
#' [create_hb_cost_test_flags()].
#' It will also produce various summary statistics for bedday, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#' @param sum_mean_vars variables used when selecting
#' 'all' measures from [calculate_measures()]
#' @param max_min_vars variables used when selecting
#' 'min-max' from [calculate_measures()]
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#'
#' @family extract test functions
#' @seealso [create_hb_test_flags()],
#' [create_hscp_test_flags()] and [create_hb_cost_test_flags()]
#' for creating test flags
#' @seealso calculate_measures
#' @export
produce_episode_file_tests <- function(
    data,
    sum_mean_vars = c("beddays", "cost", "yearstay"),
    max_min_vars = c(
      "record_keydate1", "record_keydate2",
      "cost_total_net", "yearstay"
    )) {
  test_flags <- data %>%
    dplyr::group_by(.data$recid) %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags(chi = anon_chi) %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(.data$hbtreatcode, .data$cost_total_net) %>%
    create_hscp_test_flags(.data$hscp2018) %>%
    # Flags to count stay types
    dplyr::mutate(
      cij_elective = dplyr::if_else(
        .data[["cij_pattype"]] == "Elective",
        1L,
        0L
      ),
      cij_non_elective = dplyr::if_else(
        .data[["cij_pattype"]] == "Non-Elective",
        1L,
        0L
      ),
      cij_maternity = dplyr::if_else(
        .data[["cij_pattype"]] == "Maternity",
        1L,
        0L
      ),
      cij_other = dplyr::if_else(
        .data[["cij_pattype"]] == "Other",
        1L,
        0L
      )
    )

  test_flags <- test_flags %>%
    # keep variables for comparison
    dplyr::select("unique_chi":dplyr::last_col()) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum", group_by = "recid")

  all_measures <- data %>%
    dplyr::group_by(.data$recid) %>%
    calculate_measures(
      vars = {{ sum_mean_vars }},
      measure = "all",
      group_by = "recid"
    )

  min_max <- data %>%
    dplyr::group_by(.data$recid) %>%
    calculate_measures(
      vars = {{ max_min_vars }},
      measure = "min-max",
      group_by = "recid"
    )

  join_output <- list(
    test_flags,
    all_measures,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("recid", "measure", "value"))

  return(join_output)
}
