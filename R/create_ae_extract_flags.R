#' Create the A & E Extract Flags
#'
#' @param data new or old data for testing summary flags
#'
#' @return a dataframe with additional variables containing flags
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
create_ae_extract_flags <- function(data, postcode = FALSE) {
  data %>%
    # demog flags
    create_demog_test_flags(postcode = postcode) %>%
    # create HB flags
    create_hb_test_flags(.data$hbtreatcode) %>%
    # replace missing hb with 0
    mutate(across(starts_with("NHS_"), ~ replace_na(.x, 0))) %>%
    # create HB cost flags
    create_hb_costs_test_flags(.data$cost_total_net) %>%
    # replace missing hb costs with 0
    mutate(across(starts_with("NHS_") & ends_with("_cost"), ~ replace_na(.x, 0)))
}
