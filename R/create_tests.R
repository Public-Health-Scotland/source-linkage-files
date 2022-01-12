
#' Summarise flags for testing
#'
#' @param data the data should be in a format for summarising
#'
#' @return a dataframe with a count of each flag
#' @export
sum_flags <- function(data){

data <- data %>%
  dplyr::summarise_all(sum) %>%
  tidyr::pivot_longer(
    cols = everything(),
    names_to = "measure",
    values_to = "value"
  )
}

#' Compare test files
#'
#' @param old_data dataframe containing old file
#' @param new_data dataframe containing new file
#'
#' @return a dataframe with a comparison of new and old data
#' @export
compare_tests <- function(old_data, new_data){
    dplyr::full_join(old_data, new_data, by = "measure", suffix = c("_old", "_new")) %>%
    dplyr::mutate(diff = value_old - value_new,
           pctChange = diff/value_old*100,
           issue = if_else(pctChange >= 5, 1, 0))
}


