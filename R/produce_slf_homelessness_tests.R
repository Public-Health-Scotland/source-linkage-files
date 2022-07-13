#' SLF Homelessness Extract Tests
#'
#' @param data The data for testing
#' @param max_min_vars Shouldn't need to change, currently specifies keydate1 and deydate2
#'
#' @description Produce the tests for the SLF Homelessness Extract
#'
#' @return
#'
#' @export
#' @family slf test functions
produce_slf_homelessness_tests <- function(data,
                                           max_min_vars = c("record_keydate1", "record_keydate2")) {
  test_flags <- data %>%
    # Would usually use create_demog_test_flags() here but needs to be different for Homelessness
    dplyr::arrange(.data$chi) %>%
    # create test flags
    dplyr::mutate(
      has_chi = dplyr::if_else(!is_missing(.data$chi), 1, 0),
      n_males = dplyr::if_else(.data$gender == 1, 1, 0),
      n_females = dplyr::if_else(.data$gender == 2, 1, 0),
      missing_dob = dplyr::if_else(is.na(.data$dob), 1, 0),
      hl1_main = dplyr::if_else(.data$smrtype == "HL1-Main", 1, 0),
      hl1_other = dplyr::if_else(.data$smrtype == "HL1-Other", 1, 0)
    ) %>%
    create_lca_test_flags(.data$hl1_sending_lca) %>%
    # keep variables for comparison
    dplyr::select(c(.data$has_chi:.data$West_Lothian)) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  # Calculate the minimum and maximum of {{max_min_vars}}
  min_max <- data %>%
    calculate_measures(vars = {{ max_min_vars }}, measure = "min-max")

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
