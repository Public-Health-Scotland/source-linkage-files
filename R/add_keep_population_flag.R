#' Add keep_popluation flag
#'
#' @description Add keep_population flag to individual files
#' @param individual_file individual files under processing
#' @param year the year of individual files under processing
#'
#' @return A data frame with keep_population flags
#' @family individual_file
add_keep_population_flag <- function(individual_file, year) {
  calendar_year <- paste0("20", substr(year, 1, 2)) %>% as.integer()

  if (!check_year_valid(year, "nsu")) {
    individual_file <- individual_file %>%
      dplyr::mutate(keep_population = 1L)
  } else {
    ## Obtain the population estimates for Locality AgeGroup and Gender.
    pop_estimates <-
      readr::read_rds(get_datazone_pop_path("DataZone2011_pop_est_2011_2021.rds")) %>%
      dplyr::select(year, datazone2011, sex, age0:age90plus)

    # Step 1: Obtain the population estimates for Locality, AgeGroup, and Gender
    # Select out the estimates for the year of interest.
    # if we don't have estimates for this year (and so have to use previous year).
    year_available <- pop_estimates %>%
      dplyr::pull(year) %>%
      unique()
    if (calendar_year %in% year_available) {
      pop_estimates <- pop_estimates %>%
        dplyr::filter(year == calendar_year)
    } else {
      previous_year <- sort(year_available, decreasing = TRUE)[1]
      pop_estimates <- pop_estimates %>%
        dplyr::filter(year == previous_year)
    }

    pop_estimates <- pop_estimates %>%
      # Recode gender to make it match source.
      dplyr::mutate(sex = dplyr::if_else(sex == "M", 1, 2)) %>%
      dplyr::rename(
        "age90" = "age90plus",
        "gender" = "sex"
      ) %>%
      tidyr::pivot_longer(
        names_to = "age",
        names_prefix = "age",
        values_to = "population_estimate",
        cols = "age0":"age90"
      ) %>%
      dplyr::mutate(age = as.integer(age)) %>%
      add_age_group("age") %>%
      dplyr::left_join(
        readr::read_rds(get_locality_path()) %>%
          dplyr::select("locality" = "hscp_locality", datazone2011),
        by = "datazone2011"
      ) %>%
      dplyr::group_by(locality, age_group, gender) %>%
      dplyr::summarize(population_estimate = sum(population_estimate)) %>%
      dplyr::ungroup()

    # Step 2: Work out the current population sizes in the SLF for Locality, AgeGroup, and Gender
    # Work out the current population sizes in the SLF for Locality AgeGroup and Gender.
    individual_file <- individual_file %>%
      dplyr::mutate(age = as.integer(age)) %>%
      add_age_group("age")


    set.seed(100)
    mid_year <- lubridate::dmy(stringr::str_glue("30-06-{calendar_year}"))
    ## issues with age being negative
    # If they don't have a locality, they're no good as we won't have an estimate to match them against.
    # Same for age and gender.
    nsu_keep_lookup <- individual_file %>%
      dplyr::filter(!is.na(locality), !is.na(age)) %>%
      # Remove people who died before the mid-point of the calender year.
      # This will make our numbers line up better with the methodology used for the mid-year population estimates.
      # anyone who died 5 years before the file shouldn't be in it anyway...
      dplyr::filter(death_date > mid_year | nsu != 0) %>%
      # Calculate the populations of the whole SLF and of the NSU.
      dplyr::group_by(locality, age_group, gender) %>%
      dplyr::mutate(
        nsu_population = sum(nsu),
        total_source_population = dplyr::n()
      ) %>%
      dplyr::left_join(pop_estimates,
        by = c("locality", "age_group", "gender")
      ) %>%
      dplyr::mutate(
        difference = total_source_population - population_estimate,
        new_nsu_figure = nsu_population - difference,
        scaling_factor = new_nsu_figure / nsu_population,
        scaling_factor = dplyr::case_when(scaling_factor < 0 ~ 0,
          scaling_factor > 1 ~ 1,
          .default = scaling_factor
        ),
        keep_nsu = rbinom(1, 1, scaling_factor)
      ) %>%
      dplyr::filter(keep_nsu == 1L) %>%
      dplyr::ungroup()

    # step 3: match the flag back onto the slf
    individual_file <- individual_file %>%
      dplyr::left_join(nsu_keep_lookup,
        by = "chi",
        suffix = c("", ".y")
      ) %>%
      dplyr::select(-contains(".y")) %>%
      dplyr::rename("keep_population" = "keep_nsu") %>%
      dplyr::mutate(
        # Flag all non-NSUs as Keep.
        keep_population = dplyr::if_else(nsu == 0, 1, keep_population),
        # If the flag is missing they must be a non-keep NSU so set to 0.
        keep_population = dplyr::if_else(is.na(keep_population), 0, keep_population),
      ) %>%
      dplyr::select(
        -c(
          "age_group",
          "nsu_population",
          "total_source_population",
          "population_estimate",
          "difference",
          "new_nsu_figure",
          "scaling_factor"
        )
      )
  }
}


#' add_age_group
#'
#' @description Add age group columns based on age
#' @param individual_file the individual files under processing
#' @param age_var_name the column name of age variable, could be "age"
#'
#' @return A individual file with age groups added
add_age_group <- function(individual_file, age_var_name) {
  individual_file <- individual_file %>%
    dplyr::mutate(
      age_group = dplyr::case_when(
        {{ age_var_name }} >= 0 & {{ age_var_name }} <= 4 ~ "0-4",
        {{ age_var_name }} >= 5 & {{ age_var_name }} <= 14 ~ "5-14",
        {{ age_var_name }} >= 15 & {{ age_var_name }} <= 24 ~ "15-24",
        {{ age_var_name }} >= 25 & {{ age_var_name }} <= 34 ~ "25-34",
        {{ age_var_name }} >= 35 & {{ age_var_name }} <= 44 ~ "35-44",
        {{ age_var_name }} >= 45 & {{ age_var_name }} <= 54 ~ "45-54",
        {{ age_var_name }} >= 55 & {{ age_var_name }} <= 64 ~ "55-64",
        {{ age_var_name }} >= 65 & {{ age_var_name }} <= 74 ~ "65-74",
        {{ age_var_name }} >= 75 & {{ age_var_name }} <= 84 ~ "75-84",
        {{ age_var_name }} >= 85 ~ "85+"
      )
    )
  return(individual_file)
}
