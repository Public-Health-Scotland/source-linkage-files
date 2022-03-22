#' Produce the Acute tests
#'
#' @param data new or old data for testing summary flags
#' (data is from \code{\link{get_source_extract_path}})
#'
#' @return a dataframe with a count of each flag
#' from \code{\link{sum_test_flags}}
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
#' @seealso \code{\link{create_hb_test_flags}} and
#' \code{\link{create_hscp_test_flags}} for creating test flags
produce_source_acute_tests <- function(data) {
  test_flags <- outfile %>%
    # use functions to create HB and partnership flags
    create_demog_test_flags() %>%
    create_hb_test_flags(.data$hbtreatcode) %>%
    create_hb_cost_test_flags(hbtreatcode, cost_total_net) %>%
    # remove variables that won't be summed
    select(c(valid_chi:NHS_Lanarkshire_cost))%>%
    # use function to sum new test flags
    sum_test_flags()

  create_measures<-

    check <- outfile %>%
    summarise(
      total_cost = sum(cost_total_net, na.rm = TRUE),
      mean_cost = mean(cost_total_net, na.rm = TRUE),
      total_cost_apr = sum(apr_cost, na.rm = TRUE),
      total_cost_may = sum(may_cost, na.rm = TRUE),
      total_cost_jun = sum(jun_cost, na.rm = TRUE),
      total_cost_jul = sum(jul_cost, na.rm = TRUE),
      total_cost_aug = sum(aug_cost, na.rm = TRUE),
      total_cost_sep = sum(sep_cost, na.rm = TRUE),
      total_cost_oct = sum(oct_cost, na.rm = TRUE),
      total_cost_nov = sum(nov_cost, na.rm = TRUE),
      total_cost_dec = sum(dec_cost, na.rm = TRUE),
      total_cost_jan = sum(jan_cost, na.rm = TRUE),
      total_cost_feb = sum(feb_cost, na.rm = TRUE),
      total_cost_mar = sum(mar_cost, na.rm = TRUE),
      mean_cost_apr = mean(apr_cost, na.rm = TRUE),
      mean_cost_may = mean(may_cost, na.rm = TRUE),
      mean_cost_jun = mean(jun_cost, na.rm = TRUE),
      mean_cost_jul = mean(jul_cost, na.rm = TRUE),
      mean_cost_aug = mean(aug_cost, na.rm = TRUE),
      mean_cost_sep = mean(sep_cost, na.rm = TRUE),
      mean_cost_oct = mean(oct_cost, na.rm = TRUE),
      mean_cost_nov = mean(nov_cost, na.rm = TRUE),
      mean_cost_dec = mean(dec_cost, na.rm = TRUE),
      mean_cost_jan = mean(jan_cost, na.rm = TRUE),
      mean_cost_feb = mean(feb_cost, na.rm = TRUE),
      mean_cost_mar = mean(mar_cost, na.rm = TRUE),
      total_beddays_apr = sum(apr_beddays, na.rm = TRUE),
      total_beddays_may = sum(may_beddays, na.rm = TRUE),
      total_beddays_jun = sum(jun_beddays, na.rm = TRUE),
      total_beddays_jul = sum(jul_beddays, na.rm = TRUE),
      total_beddays_aug = sum(aug_beddays, na.rm = TRUE),
      total_beddays_sep = sum(sep_beddays, na.rm = TRUE),
      total_beddays_oct = sum(oct_beddays, na.rm = TRUE),
      total_beddays_nov = sum(nov_beddays, na.rm = TRUE),
      total_beddays_dec = sum(dec_beddays, na.rm = TRUE),
      total_beddays_jan = sum(jan_beddays, na.rm = TRUE),
      total_beddays_feb = sum(feb_beddays, na.rm = TRUE),
      total_beddays_mar = sum(mar_beddays, na.rm = TRUE),
      mean_beddays_apr = mean(apr_beddays, na.rm = TRUE),
      mean_beddays_may = mean(may_beddays, na.rm = TRUE),
      mean_beddays_jun = mean(jun_beddays, na.rm = TRUE),
      mean_beddays_jul = mean(jul_beddays, na.rm = TRUE),
      mean_beddays_aug = mean(aug_beddays, na.rm = TRUE),
      mean_beddays_sep = mean(sep_beddays, na.rm = TRUE),
      mean_beddays_oct = mean(oct_beddays, na.rm = TRUE),
      mean_beddays_nov = mean(nov_beddays, na.rm = TRUE),
      mean_beddays_dec = mean(dec_beddays, na.rm = TRUE),
      mean_beddays_jan = mean(jan_beddays, na.rm = TRUE),
      mean_beddays_feb = mean(feb_beddays, na.rm = TRUE),
      mean_beddays_mar = mean(mar_beddays, na.rm = TRUE)
      ) %>%
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "measure",
      values_to = "value"
    ) %>%
    mutate(value = format(round(value, digits = 2), scientific = F))

  join_output <- full_join(test_flags, create_measures)

  return(join_output)

}
