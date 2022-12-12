#' Match on LTC changed_dob and dates of LTC incidence (based on hospital incidence only)
#'
#' @description Match on LTC changed_dob and dates of LTC incidence (based on hospital incidence only)
#'
#' @param data episode files
#' @param year financial year, eg '1920'
#'
#' @return data matched with long term conditions
#' @export
#'
#' @examples match_on_ltcs(data, "1920")
match_on_ltcs <- function(data, year) {
  # Match on LTC lookup
  matched <- dplyr::left_join(
    data,
    readr::read_rds(get_ltcs_path(year)),
    by = "chi",
    suffix = c("", "_ltc")
  ) %>%
    # Replace any NA values with 0 for the LTC flags
    dplyr::mutate(dplyr::across("arth":"digestive", ~ tidyr::replace_na(., 0)))
  return(matched)
}
