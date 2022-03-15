#' Produce the Prescribing Extract Test
#'
#' @param data new or old data for summarising flags
#'
#' @return a dataframe with additional variables containing flags
#' @export
#' @importFrom dplyr mutate select
#' @family produce tests functions
#' @seealso \code{\link{create_pis_extract_flags}} and
produce_pis_extract_test <- function(data) {
  data %>%
    summarise(
      n_chi = sum(valid_chi, na.rm = TRUE),
      unique_chi = sum(unique_chi, na.rm = TRUE),
      n_missing_chi = sum(n_missing_chi, na.rm = TRUE),
      n_male = sum(n_males, na.rm = TRUE),
      n_female = sum(n_females, na.rm = TRUE),
      missing_dob = sum(missing_dob, na.rm = TRUE),
      mean_cost = mean(cost_total_net, na.rm = TRUE),
      total_cost = sum(cost_total_net, na.rm = TRUE),
      mean_dispensed = mean(no_dispensed_items, na.rm = TRUE),
      total_dispensed = sum(no_dispensed_items, na.rm = TRUE)
    ) %>%
    mutate_all(as.character) %>%
    tidyr::pivot_longer(
      cols = everything(),
      names_to = "measure",
      values_to = "value",
      values_ptypes = list(value = as.character())
    )
}
