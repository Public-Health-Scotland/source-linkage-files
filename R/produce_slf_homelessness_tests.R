#' SLF Homelessness Extract Tests
#'
#' @param new_data The new data for testing
#' @param existing_data The existing data for testing
#'
#' @description Produce the tests for the SLF Homelessness Extract
#'
#' @return A dataframe with counts of records, their differences, and proportional differences
#'
#' @export
#' @family slf test functions
produce_slf_homelessness_tests <- function(new_data, existing_data) {
  new_data <- new_data %>%
    dplyr::mutate(age = dplyr::case_when(
      age %in% c(-1:17) ~ "<18",
      age %in% c(18:44) ~ "18-45",
      age %in% c(45:64) ~ "45-64",
      age %in% c(65:84) ~ "65-84",
      age >= 85 ~ "85+",
      TRUE ~ "Missing"
    )) %>%
    dplyr::group_by(hl1_sending_lca, smrtype, age) %>%
    dplyr::summarise(records_new = dplyr::n())

  existing_data <- existing_data %>%
    dplyr::mutate(age = dplyr::case_when(
      age %in% c(-1:17) ~ "<18",
      age %in% c(18:44) ~ "18-45",
      age %in% c(45:64) ~ "45-64",
      age %in% c(65:84) ~ "65-84",
      age >= 85 ~ "85+",
      TRUE ~ "Missing"
    )) %>%
    dplyr::group_by(hl1_sending_lca, smrtype, age) %>%
    dplyr::summarise(records_old = dplyr::n())

  comparison <- dplyr::full_join(new_data, existing_data) %>%
    dplyr::mutate(
      record_change = records_new - records_old,
      record_proportion = abs((records_new - records_old) / records_old * 100)
    ) %>%
    dplyr::arrange(desc(record_proportion))

  return(comparison)
}
