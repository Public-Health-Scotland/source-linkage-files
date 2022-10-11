# Get temp file
temp <- haven::read_sav("/conf/sourcedev/Source_Linkage_File_Updates/1920/temp-source-episode-file-4-1920.zsav",
  n_max = 100000
)

# Match on LTC lookup
matched <- dplyr::left_join(temp,
  readr::read_rds(get_ltcs_path("1920")),
  by = "chi",
  suffix = c("", "_ltc")
) %>%
  # Replace any NA values with 0 for the LTC flags
  dplyr::mutate(dplyr::across(arth:digestive, ~ tidyr::replace_na(., 0)))

# Checking and changing DOB and age
test <- matched %>%
  dplyr::filter(!is_missing(chi)) %>%
  dplyr::mutate(
    # Create a dob in the previous century from the chi number
    chi_dob_min = phsmethods::dob_from_chi(
      chi_number = chi,
      chi_check = FALSE,
      min_date = lubridate::ymd("1900-01-01"),
      max_date = lubridate::ymd("2000-01-01")
    ),
    # Create a dob in the current century from chi (will return NA if in the future)
    chi_dob_max = phsmethods::dob_from_chi(
      chi_number = chi,
      chi_check = FALSE,
      min_date = lubridate::ymd("2000-01-01")
    ),
    # Compute two ages for each chi, the maximum and minimum it could be
    chi_age_max = compute_mid_year_age("1920", chi_dob_min),
    chi_age_min = compute_mid_year_age("1920", chi_dob_max),
    # Mutate age based on different scenarios
    age = dplyr::case_when(
      # Case when the dob is already valid
      .data$dob == chi_dob_min ~ chi_age_max,
      .data$dob == chi_dob_max ~ chi_age_min,
      # If one option for dob isn't there, use the other
      is.na(chi_dob_min) & !is.na(chi_dob_max) ~ chi_age_min,
      !is.na(chi_dob_min) & is.na(chi_dob_max) ~ chi_age_max,
      # If the age would be negative, use the older
      chi_age_min < 0 ~ chi_age_max,
      # If they have activity before birth date, assume older
      chi_dob_max > keydate1_dateformat ~ chi_age_max,
      # If they have an LTC date before birth date, assume older
      chi_dob_max > purrr::reduce(dplyr::select(., arth_date:digestive_date), `min`) ~ chi_age_max,
      # If they have a maternity record, assume the younger age
      chi_age_max > 3 & recid == "02B" ~ chi_age_min,
      # If they have a GLS record and the age is broadly correct, assume older
      dplyr::between(chi_age_max, 50, 130) & recid == "GLS" ~ chi_age_max,
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
      is.na(chi_dob_min) & !is.na(chi_dob_max) ~ chi_dob_max,
      !is.na(chi_dob_min) & is.na(chi_dob_max) ~ chi_dob_min,
      # If the age would be negative, use the older
      chi_age_min < 0 ~ chi_dob_min,
      # If they have activity before birth date, assume older
      chi_dob_max > keydate1_dateformat ~ chi_dob_min,
      # If they have an LTC date before birth date, assume older
      chi_dob_max > purrr::reduce(dplyr::select(., arth_date:digestive_date), `min`) ~ chi_dob_min,
      # If they have a maternity record, assume the younger age
      chi_age_max > 3 & recid == "02B" ~ chi_dob_max,
      # If they have a GLS record and the age is broadly correct, assume older
      dplyr::between(chi_age_max, 50, 130) & recid == "GLS" ~ chi_dob_min,
      # If a congenital defect lines up with a dob, assume it is correct
      chi_dob_max == congen_date ~ chi_dob_max,
      chi_dob_min == congen_date ~ chi_dob_min,
      # If being older makes them over 113, assume they are younger
      chi_age_max > 113 ~ chi_dob_max
    ),
    # Create a new variable that explains why the dob and age were changed or not changed
    changed_dob = dplyr::case_when(
      # Case when the dob is already valid
      .data$dob == chi_dob_min ~ 1,
      .data$dob == chi_dob_max ~ 1,
      # If one option for dob isn't there, use the other
      is.na(chi_dob_min) & !is.na(chi_dob_max) ~ 2,
      !is.na(chi_dob_min) & is.na(chi_dob_max) ~ 2,
      # If the age would be negative, use the older
      chi_age_min < 0 ~ 3,
      # If they have activity before birth date, assume older
      chi_dob_max > keydate1_dateformat ~ 4,
      # If they have an LTC date before birth date, assume older
      chi_dob_max > purrr::reduce(dplyr::select(., arth_date:digestive_date), `min`) ~ 5,
      # If they have a maternity record, assume the younger age
      chi_age_max > 3 & recid == "02B" ~ 6,
      # If they have a GLS record and the age is broadly correct, assume older
      dplyr::between(chi_age_max, 50, 130) & recid == "GLS" ~ 7,
      # If a congenital defect lines up with a dob, assume it is correct
      chi_dob_max == congen_date ~ 8,
      chi_dob_min == congen_date ~ 8,
      # If being older makes them over 113, assume they are younger
      chi_age_max > 113 ~ 9
    )
  ) %>%
  # Situation where we still don't have an age, look at other records with the same
  # chi and try and get it from there
  dplyr::group_by(chi) %>%
  # dplyr::mutate(age = dplyr::case_when(
  #   is.na(age) & (chi_dob_min == lag(dob) | chi_age_max == lag(age)) ~ chi_age_max,
  #   is.na(age) & (chi_dob_max == lag(dob) | chi_age_min == lag(age)) ~ chi_age_min,
  #   TRUE ~ age),
  # dob = dplyr::case_when(
  #   is.na(age) & (chi_dob_min == lag(dob) | chi_age_max == lag(age)) ~ chi_dob_min,
  #   is.na(age) & (chi_dob_max == lag(dob) | chi_age_min == lag(age)) ~ chi_dob_max,
  #   TRUE ~ dob),
  # changed_dob = dplyr::case_when(
  #   is.na(age) & (chi_dob_min == lag(dob) | chi_age_max == lag(age)) ~ 10,
  #   is.na(age) & (chi_dob_max == lag(dob) | chi_age_min == lag(age)) ~ 10,
  #   TRUE ~ changed_dob)) %>%
  dplyr::arrange(desc(age)) %>%
  tidyr::fill(age, .direction = "down") %>%
  dplyr::ungroup()



test2 <- test %>% dplyr::select(chi, dob, age, changed_dob)
