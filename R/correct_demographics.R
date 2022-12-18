#' Correct date of birth and ages of records
#'
#' @description Correct date of birth and ages of records
#'
#' @param data episode files
#' @param year financial year, eg '1920'
#'
#' @return episode files with updated date of birth and ages
#' @export
#'
#' @examples match_on_ltcs(data, "1920")
correct_demographics <- function(data, year) {
  # Checking and changing DOB and age
  data <- data %>%
    dplyr::filter(!is_missing(chi)) %>%
    dplyr::mutate(
      # Create a dob in the previous century from the chi number
      chi_dob_min = phsmethods::dob_from_chi(
        chi_number = chi,
        chi_check = FALSE,
        min_date = lubridate::ymd("1900-01-01"),
        max_date = pmin(keydate1_dateformat, lubridate::ymd("1999-12-31"), na.rm = TRUE)
      ),
      # Create a dob in the current century from chi (will return NA if in the future)
      chi_dob_max = phsmethods::dob_from_chi(
        chi_number = chi,
        chi_check = FALSE,
        min_date = lubridate::ymd("2000-01-01"),
        max_date = pmax(keydate1_dateformat, lubridate::ymd("2000-01-01"), na.rm = TRUE)
      ),

      # Compute two ages for each chi, the maximum and minimum it could be
      chi_age_max = compute_mid_year_age(year, chi_dob_min),
      chi_age_min = compute_mid_year_age(year, chi_dob_max),

      # change dob based on scenarios ONLY IF dob is missing
      dob = dplyr::case_when(
        # DO NOT change dob when it is already there
        !is.na(.data$dob) ~ dob,
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
    # Fill in the ages for any that are left.
    dplyr::mutate(
      age = compute_mid_year_age(year, dob),
) %>% 
      # Fill in gender from CHI if it's missing.
      dplyr::mutate(
      chi_gender = phsmethods::sex_from_chi(chi),
      gender = as.integer(gender),
      gender = dplyr::if_else(!is.na(chi_gender) &
        (is.na(gender) | gender == 0L),
      chi_gender,
      gender
      )
    ) %>%
    # delete temporary variables
    dplyr::select(-c(
      "chi_dob_min",
      "chi_dob_max",
      "chi_age_max",
      "chi_age_min",
      "chi_gender"
    ))

  # return the data
  return(data)
}
