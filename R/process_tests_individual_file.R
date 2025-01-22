#' Process Individual file tests
#'
#' @description Takes the processed individual file and produces
#' a test comparison with the previous data. This is written to disk as an xlsx.
#'
#' @inherit process_tests_acute
#'
#' @export
process_tests_individual_file <- function(data, year) {
  data <- data %>%
    dplyr::select(
      "year",
      "anon_chi",
      "gender",
      "postcode",
      "dob",
      "hbrescode",
      "health_net_cost",
      slfhelper::ltc_vars,
      dplyr::contains(c(
        "beddays",
        "cost",
        "episodes",
        "attendances",
        "admissions",
        "cases",
        "consultations"
      ))
    )

  old_data <- get_existing_data_for_tests(data, file_version = "individual", anon_chi = TRUE)

  comparison <- produce_test_comparison(
    old_data = produce_individual_file_tests(old_data),
    new_data = produce_individual_file_tests(data)
  ) %>%
    write_tests_xlsx(
      sheet_name = stringr::str_glue({
        "indiv_file_{year}"
      }),
      year = year,
      workbook_name = "indiv_file"
    )

  return(comparison)
}

#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by most
#' of the extracts.
#' This will produce counts of various demographics
#' using [create_demog_test_flags()] counts of episodes for every `hbrescode`
#' using [create_hb_test_flags()], a total cost for each `hbrescode` using
#' [create_hb_cost_test_flags()].
#' It will also produce various summary statistics for bedday, cost and
#' episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
produce_individual_file_tests <- function(data) {
  names(data) <- tolower(names(data))

  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    create_hb_test_flags(.data$hbrescode) %>%
    create_hb_cost_test_flags(.data$hbrescode, .data$health_net_cost) %>%
    # keep variables for comparison
    dplyr::select(c("unique_chi":dplyr::last_col())) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  all_measures <- data %>%
    calculate_measures(
      vars = c(
        "beddays",
        "cost",
        "episodes",
        "attendances",
        "admissions",
        "cases",
        "consultations"
      ),
      measure = "all"
    )

  min_max_measures <- data %>%
    calculate_measures(
      vars = c(
        "health_net_cost"
      ),
      measure = "min-max"
    )

  sum_measures <- data %>%
    dplyr::select(slfhelper::ltc_vars) %>%
    calculate_measures(
      vars = c(
        slfhelper::ltc_vars
      ),
      measure = "sum"
    )

  dup_chi <- data.frame(
    measure = "duplicated chi number",
    value = duplicated(data$chi) %>%
      sum() %>% as.integer()
  )

  join_output <- list(
    test_flags,
    all_measures,
    min_max_measures,
    sum_measures,
    dup_chi
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
