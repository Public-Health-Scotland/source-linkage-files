#' Produce the Postcode Lookup tests
#'
#' @param data new or old data for testing summary flags
#' (data is from \code{\link{get_slf_postcode_path}})
#'
#' @return a dataframe with a count of each flag
#' from \code{\link{sum_test_flags}}
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
#' @seealso \code{\link{create_hb_test_flags}} and
#' \code{\link{create_hscp_test_flags}} for creating test flags
produce_slf_postcode_tests <- function(data) {
  data %>%
    # use functions to create HB and partnership flags
    create_hb_test_flags(.data$HB2019) %>%
    create_hscp_test_flags(.data$HSCP2019) %>%
    # create other test flags
    mutate(n_postcode = 1) %>%
    # remove variables that are not test flags
    select(-c(
      .data$postcode, .data$HB2018, .data$HSCP2018, .data$CA2018,
      .data$LCA, .data$Locality, .data$DataZone2011, .data$HB2019,
      .data$CA2019, .data$HSCP2019, .data$SIMD2020v2_rank,
      .data$simd2020v2_sc_decile, .data$simd2020v2_sc_quintile,
      .data$simd2020v2_hb2019_decile, .data$simd2020v2_hb2019_quintile,
      .data$simd2020v2_hscp2019_decile, .data$simd2020v2_hscp2019_quintile,
      .data$UR8_2016, .data$UR6_2016, .data$UR3_2016, .data$UR2_2016
    )) %>%
    # use function to sum new test flags
    sum_test_flags()
}
