#' Match on LTC DoB and dates of LTC incidence
#'
#' @description Match on LTC changed_dob and dates of LTC incidence
#' (based on hospital incidence only).
#'
#' @param data episode files
#' @param year financial year, e.g. '1920'
#'
#' @return data matched with long term conditions
#' @export
match_on_ltcs <- function(data, year) {
  # Match on LTC lookup
  matched <- dplyr::left_join(
    data,
    readr::read_rds(get_ltcs_path(year)),
    by = "chi",
    suffix = c("", "_ltc")
  ) %>%
    dplyr::mutate(
      # Replace any NA values with 0 for the LTC flags
      dplyr::across("arth":"digestive", ~ tidyr::replace_na(., 0)),
      # Use the postcode from the LTC file if it's otherwise missing
      postcode = dplyr::if_else(is.na(.data$postcode),
        .data$postcode_ltc,
        .data$postcode
      )
    ) %>%
    dplyr::select(-tidyselect::ends_with("_ltc"))

  return(matched)
}