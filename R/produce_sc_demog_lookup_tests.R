#' Produce the Social Care Demographic Lookup tests
#'
#' @param data new or old data for testing summary flags
#' (data is from \code{\link{get_sc_demog_lookup_path}})
#'
#' @return a dataframe with a count of each flag.
#'
#' @export
#' @importFrom dplyr mutate if_else
#' @family produce tests functions
produce_sc_demog_lookup_tests <- function(data) {
  data %>%
    # create test flags
    create_demog_test_flags() %>%
    mutate(
      n_missing_sending_loc = if_else(is_missing(.data$sending_location), 1, 0),
      n_missing_sc_id = if_else(is_missing(.data$social_care_id), 1, 0)
    ) %>%
    # remove variables that won't be summed
    select(
      -c(
        .data$sending_location,
        .data$social_care_id,
        .data$chi,
        .data$gender,
        .data$dob,
        .data$postcode
      )
    ) %>%
    # use function to sum new test flags
    calculate_measures(measure = "sum")
}
