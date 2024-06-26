#' Join Deaths data
#'
#' @param data Episode file data
#' @param year financial year, e.g. '1920'
#' @param slf_deaths_lookup The SLF deaths lookup.
#'
#' @return The data including the deaths lookup matched
#'         on to the episode file.
join_deaths_data <- function(
    data,
    year,
    slf_deaths_lookup = read_file(get_slf_deaths_lookup_path(year)) %>% slfhelper::get_chi()) {
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
