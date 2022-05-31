#' Produce the Postcode Lookup tests
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_postcode_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#' @family produce tests functions
#' @seealso [create_hb_test_flags()] and
#' [create_hscp_test_flags()] for creating test flags
produce_slf_postcode_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$hb2019) %>%
    create_hscp_test_flags(.data$hscp2019) %>%
    # create other test flags
    dplyr::mutate(n_postcode = 1) %>%
    # remove variables that are not test flags
    dplyr::select(-c(
      .data$postcode, .data$hb2018, .data$hscp2018, .data$ca2018,
      .data$lca, .data$locality, .data$datazone2011, .data$hb2019,
      .data$ca2019, .data$hscp2019, .data$simd2020v2_rank,
      .data$simd2020v2_sc_decile, .data$simd2020v2_sc_quintile,
      .data$simd2020v2_hb2019_decile, .data$simd2020v2_hb2019_quintile,
      .data$simd2020v2_hscp2019_decile, .data$simd2020v2_hscp2019_quintile,
      .data$ur8_2016, .data$ur6_2016, .data$ur3_2016, .data$ur2_2016
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
