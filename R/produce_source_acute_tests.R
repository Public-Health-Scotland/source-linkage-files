#' Produce the Acute tests
#'
#' @param data new or old data for testing summary flags
#' (data is from \code{\link{get_source_extract_path}})
#'
#' @return a dataframe with a count of each flag
#' from \code{\link{sum_test_flags}}
#' @export
#'
#' @family produce tests functions
#' @seealso \code{\link{create_hb_test_flags}},
#' \code{\link{create_hscp_test_flags}} and \code{\link{create_hb_cost_test_flags}}
#' for creating test flags
produce_source_acute_tests <- function(data) {
  test_flags <- data %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(hbtreatcode, cost_total_net) %>%
    # remove variables that won't be summed
    select(c(valid_chi:NHS_Lanarkshire_cost))%>%
    # use function to sum new test flags
    sum_test_flags()

  calculate_measures<- data %>%
    calculate_measures(vars = c("beddays", "cost", "yearstay"))


  join_output <- full_join(test_flags, calculate_measures)

  return(join_output)

}
