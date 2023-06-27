#' Join Deaths data
#'
#' @param ep_file_data Episode file data
#' @param year financial year, e.g. '1920'
#' @param slf_deaths_lookup_path Path to slf deaths lookup.
#'
#' @return The data including the deaths lookup matched
#'         on to the episode file.
join_deaths_data <- function(
    data,
    year,
    slf_deaths_lookup_path = get_slf_deaths_lookup_path(year)) {
  slf_deaths_lookup <- read_file(slf_deaths_lookup_path)

  return(
    data %>%
      dplyr::left_join(
        slf_deaths_lookup,
        by = "chi",
        na_matches = "never",
        relationship = "many-to-one"
      )
  )
}
