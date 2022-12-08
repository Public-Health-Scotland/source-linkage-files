#' Match on LTC changed_dob and dates of LTC incidence (based on hospital incidence only)
#'
#' @description Match on LTC changed_dob and dates of LTC incidence (based on hospital incidence only)
#'
#' @param
#'
#' @return
#' @export
#'
#' @examples
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
  matched <- correct_demographics(matched, year)
  return(matched)
}

correct_demographics <- function(data, year) {
  # Checking and changing DOB and age
  # data <- data %>%
  test <- data %>%
    dplyr::filter(!is_missing(chi)) %>%
    dplyr::mutate(
      # Create a dob in the previous century from the chi number
      chi_dob_min = phsmethods::dob_from_chi(
        chi_number = chi,
        chi_check = FALSE,
        min_date = lubridate::ymd("1900-01-01"),
        max_date = lubridate::ymd("1999-12-31")
      ),
      # Create a dob in the current century from chi (will return NA if in the future)
      chi_dob_max = phsmethods::dob_from_chi(
        chi_number = chi,
        chi_check = FALSE,
        min_date = lubridate::ymd("2000-01-01"),
        max_date = end_fy(year)
      ),
      # Compute two ages for each chi, the maximum and minimum it could be
      chi_age_max = compute_mid_year_age(year, chi_dob_min),
      chi_age_min = compute_mid_year_age(year, chi_dob_max),
      # Mutate age based on different scenarios
      age = dplyr::case_when(
        # Case when the dob is already valid
        .data$dob == chi_dob_min ~ chi_age_max,
        .data$dob == chi_dob_max ~ chi_age_min,
        # If one option for dob isn't there, use the other
        is.na(chi_dob_min) &
          !is.na(chi_dob_max) ~ chi_age_min, !is.na(chi_dob_min) &
          is.na(chi_dob_max) ~ chi_age_max,
        # If they have an LTC date before birth date, assume older
        chi_dob_max > purrr::reduce(dplyr::select(., "arth_date":"digestive_date"), `min`) ~ chi_age_max,
        # If they have a GLS record and the age is broadly correct, assume older
        dplyr::between(chi_age_max, 50, 130) &
          recid == "GLS" ~ chi_age_max,
        # If a congenital defect lines up with a dob, assume it is correct
        chi_dob_max == congen_date ~ chi_age_min,
        chi_dob_min == congen_date ~ chi_age_max,
        # If being older makes them over 113, assume they are younger
        chi_age_max > 113 ~ chi_age_min
      ),
      # For the same scenarios, mutate dob
      dob = dplyr::case_when(
        # Case when the dob is already valid
        .data$dob == chi_dob_min ~ dob,
        .data$dob == chi_dob_max ~ dob,
        # If one option for dob isn't there, use the other
        is.na(chi_dob_min) &
          !is.na(chi_dob_max) ~ chi_dob_max, !is.na(chi_dob_min) &
          is.na(chi_dob_max) ~ chi_dob_min,
        # If they have an LTC date before birth date, assume older
        chi_dob_max > purrr::reduce(dplyr::select(., "arth_date":"digestive_date"), `min`) ~ chi_dob_min,
        # If they have a GLS record and the age is broadly correct, assume older
        dplyr::between(chi_age_max, 50, 130) &
          recid == "GLS" ~ chi_dob_min,
        # If a congenital defect lines up with a dob, assume it is correct
        chi_dob_max == congen_date ~ chi_dob_max,
        chi_dob_min == congen_date ~ chi_dob_min,
        # If being older makes them over 113, assume they are younger
        chi_age_max > 113 ~ chi_dob_max
      )
    ) %>%
    # If we still don't have an age, try and fill it in from other records.
    dplyr::group_by(chi) %>%
    tidyr::fill(dob, .direction = "downup") %>%
    dplyr::ungroup() %>%
    # Fill in ages for any that are left.
    dplyr::mutate(age = dplyr::if_else(is.na(age), compute_mid_year_age(year, dob), age)) %>%
    # If any gender codes are missing or 0 recode to CHI gender.
    dplyr::mutate(chi_gender = phsmethods::sex_from_chi(chi))

  # return the data
  return(test)
}
