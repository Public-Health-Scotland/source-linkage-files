#' SLF Postcode Lookup Tests
#'
#' @description Produce the tests for the SLF Postcode Lookup
#'
#' @param data new or old data for testing summary flags
#' (data is from [get_slf_postcode_path()])
#'
#' @return a dataframe with a count of each flag
#' from [calculate_measures()]
#' @export
#' @family slf test functions
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
      "postcode", "hb2018", "hscp2018", "ca2018",
      "lca", "locality", "datazone2011", "hb2019",
      "ca2019", "hscp2019", "simd2020v2_rank",
      "simd2020v2_sc_decile", "simd2020v2_sc_quintile",
      "simd2020v2_hb2019_decile", "simd2020v2_hb2019_quintile",
      "simd2020v2_hscp2019_decile", "simd2020v2_hscp2019_quintile",
      "ur8_2016", "ur6_2016", "ur3_2016", "ur2_2016"
    )) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
