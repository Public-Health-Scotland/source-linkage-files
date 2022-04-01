# -------------------------------------------------------------------------------------------

## tests ##

## functions inc in another branch
create_demog_test_flags <- function(data, postcode = TRUE) {
  if (postcode == TRUE) {
    data %>%
      arrange(.data$chi) %>%
      # create test flags
      mutate(
        valid_chi = if_else(phsmethods::chi_check(.data$chi) == "Valid CHI", 1, 0),
        unique_chi = if_else(dplyr::lag(.data$chi) != .data$chi, 1, 0),
        n_missing_chi = if_else(is_missing(.data$chi), 1, 0),
        n_males = if_else(.data$gender == 1, 1, 0),
        n_females = if_else(.data$gender == 2, 1, 0),
        n_postcode = if_else(is.na(.data$postcode) | .data$postcode == "", 0, 1),
        n_missing_postcode = if_else(is_missing(.data$postcode), 1, 0),
        missing_dob = if_else(is.na(.data$dob), 1, 0)
      )
  } else {
    data %>%
      arrange(.data$chi) %>%
      # create test flags
      mutate(
        valid_chi = if_else(phsmethods::chi_check(.data$chi) == "Valid CHI", 1, 0),
        unique_chi = if_else(dplyr::lag(.data$chi) != .data$chi, 1, 0),
        n_missing_chi = if_else(is_missing(.data$chi), 1, 0),
        n_males = if_else(.data$gender == 1, 1, 0),
        n_females = if_else(.data$gender == 2, 1, 0),
        missing_dob = if_else(is.na(.data$dob), 1, 0)
      )
  }
}

create_hb_costs_test_flags <- function(data, cost_var) {
  data <- data %>%
    mutate(
      NHS_Ayrshire_and_Arran_cost = if_else(NHS_Ayrshire_and_Arran == 1, {{ cost_var }}, 0),
      NHS_Borders_cost = if_else(NHS_Borders == 1, {{ cost_var }}, 0),
      NHS_Dumfries_and_Galloway_cost = if_else(NHS_Dumfries_and_Galloway == 1, {{ cost_var }}, 0),
      NHS_Forth_Valley_cost = if_else(NHS_Forth_Valley == 1, {{ cost_var }}, 0),
      NHS_Grampian_cost = if_else(NHS_Grampian == 1, {{ cost_var }}, 0),
      NHS_Highland_cost = if_else(NHS_Highland == 1, {{ cost_var }}, 0),
      NHS_Lothian_cost = if_else(NHS_Lothian == 1, {{ cost_var }}, 0),
      NHS_Orkney_cost = if_else(NHS_Orkney == 1, {{ cost_var }}, 0),
      NHS_Shetland_cost = if_else(NHS_Shetland == 1, {{ cost_var }}, 0),
      NHS_Western_Isles_cost = if_else(NHS_Western_Isles == 1, {{ cost_var }}, 0),
      NHS_Fife_cost = if_else(NHS_Fife == 1, {{ cost_var }}, 0),
      NHS_Tayside_cost = if_else(NHS_Tayside == 1, {{ cost_var }}, 0),
      NHS_Greater_Glasgow_and_Clyde_cost = if_else(NHS_Greater_Glasgow_and_Clyde == 1, {{ cost_var }}, 0),
      NHS_Lanarkshire_cost = if_else(NHS_Lanarkshire == 1, {{ cost_var }}, 0)
    )
}

create_outpatient_extract_flags <- function(data, postcode = FALSE) {
  data %>%
    # demog flags
    create_demog_test_flags(postcode = postcode) %>%
    # create HB flags
    create_hb_test_flags(.data$hbtreatcode) %>%
    # replace missing hb with 0
    mutate(across(starts_with("NHS_"), ~ replace_na(.x, 0))) %>%
    # create HB cost flags
    create_hb_costs_test_flags(.data$cost_total_net) %>%
    # replace missing hb costs with 0
    mutate(across(starts_with("NHS_") & ends_with("_cost"), ~ replace_na(.x, 0)))
}
##

## Flags ##
outpatient_flags <- create_outpatient_extract_flags(outfile, postcode = FALSE)


## values for whole file ##
slf_new <- produce_outpatient_extract_test(outpatient_flags)


# -------------------------------------------------------------------------------------------


## get data ##

episode_file <- read_slf_episode(latest_year,
                                 recid = c("00B"),
                                 columns = c("recid",
                                             "anon_chi",
                                             "record_keydate1",
                                             "record_keydate2",
                                             "gender",
                                             "dob",
                                             "age",
                                             "hbtreatcode",
                                             "cost_total_net",
                                             "apr_cost",
                                             "may_cost",
                                             "jun_cost",
                                             "jul_cost",
                                             "aug_cost",
                                             "sep_cost",
                                             "oct_cost",
                                             "nov_cost",
                                             "dec_cost",
                                             "jan_cost",
                                             "feb_cost",
                                             "mar_cost",
                                             "attendance_status")
)


# read anon chi lookup
anonchi_lookup <- haven::read_sav("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav")



episode_file_updated_chi <-
  episode_file %>%
  left_join(anonchi_lookup, by = "anon_chi") %>%
  # reorder
  select(
    recid,
    chi,
    record_keydate1,
    record_keydate2,
    gender,
    dob,
    age,
    hbtreatcode,
    cost_total_net,
    ends_with("_cost")) %>%
  # date type
  mutate(across(contains("_keydate"), .x = as.Date(.x)))


## Flags ##
episode_flags <- create_outpatient_extract_flags(episode_file_updated_chi, postcode = FALSE)


## values for whole file ##
slf_existing <- produce_outpatient_extract_test(episode_flags, postcode = FALSE)


# -------------------------------------------------------------------------------------------

# function here till merged
extract_comparison_test <- function(slf_new, slf_existing) {

  ## match ##

  comparison <-
    slf_new %>%
    full_join(slf_existing, by = c("measure")) %>%
    # rename
    rename(
      new_value = "value.x",
      existing_value = "value.y"
    ) %>%
    mutate(
      new_value = as.numeric(new_value),
      existing_value = as.numeric(existing_value)
    )


  ## comparison ##

  comparison <-
    comparison %>%
    mutate(difference = new_value - existing_value) %>%
    mutate(pct_change = if_else(existing_value != 0, difference / existing_value * 100, 0)) %>%
    mutate(issue = abs(pct_change) > 5)
}

## run comparison function
comparison <- extract_comparison_test(slf_new = slf_new, slf_existing = slf_existing)


# check if any issues in the comparison
any(comparison$issue == TRUE)


# plot issues
comparison %>%
  filter(issue == TRUE) %>%
  ggplot(aes(x = measure, y = difference)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

comparison %>%
  filter(issue == TRUE) %>%
  ggplot(aes(x = measure, y = pct_change)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


## save outfile ##

# .zsav
haven::write_sav(outpatient_comparison,
                 paste0(
                   get_year_dir(year = latest_year),
                   "/Outpatient_tests_20",
                   latest_year, ".zsav"
                 ),
                 compress = TRUE
)

# .rds file
readr::write_rds(outpatient_comparison,
                 paste0(
                   get_year_dir(year = latest_year),
                   "/Outpatient_tests_20",
                   latest_year, ".zsav"
                 ),
                 compress = "gz"
)
