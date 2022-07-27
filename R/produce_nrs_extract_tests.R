#' Source Extract Tests
#'
#' @description Produce a set of tests which can be used by the death (NRS) extract
#'
#' This will produce counts of various demographics.
#' It will also produce various summary statistics for episode date variables.
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_source_extract_path()])
#' @param max_min_vars variables used when selecting 'min-max' from [calculate_measures()]
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#'
#' @family extract test functions
#' @seealso [calculate_measures()]
produce_nrs_extract_tests <- function(data,
                                      max_min_vars = c(
                                        "record_keydate1", "record_keydate2"
                                      )) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    dplyr::arrange(.data$chi) %>%
    # create test flags
    create_demog_test_flags() %>%
    mutate(n_deaths = 1)
  # keep variables for comparison
  dplyr::select(c(.data$valid_chi:.data$n_deaths)) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")

  min_max <- data %>%
    calculate_measures(vars = {{ max_min_vars }}, measure = "min-max")

  join_output <- list(
    test_flags,
    min_max
  ) %>%
    purrr::reduce(dplyr::full_join, by = c("measure", "value"))

  return(join_output)
}
