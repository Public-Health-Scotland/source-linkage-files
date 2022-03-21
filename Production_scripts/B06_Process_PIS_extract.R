#####################################################
# Prescribing Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process Prescribing Extract
#####################################################

library(dplyr)
library(createslf)
library(slfhelper)


# Read in data ---------------------------------------

# latest year
latest_year <- 1920

pis_extract <- readr::read_csv(
  get_it_prescribing_path(latest_year)
) %>%
  # rename
  rename(
    chi = "Pat UPI [C]",
    dob = "Pat DoB [C]",
    gender = "Pat Gender",
    postcode = "Pat Postcode [C]",
    gpprac = "Practice Code",
    no_dispensed_items = "Number of Dispensed Items",
    cost_total_net = "DI Paid NIC excl. BB"
  ) %>%
  # de-select "DI Paid GIC excl. BB"
  select(-c(`DI Paid GIC excl. BB`)) %>%
  # filter for chi NA
  filter(!is.na(chi)) %>%
  # create variables recid and year
  mutate(
    recid = "PIS",
    year = latest_year
  )


# Recode GP Practice into a 5 digit number ---------------------------------------

# assume that if it starts with a letter it's an English practice and so recode to 99995
pis_extract <-
  pis_extract %>%
  eng_gp_to_dummy(gpprac)


# Set date to the end of the FY ---------------------------------------
pis_extract <-
  pis_extract %>%
  mutate(record_keydate1 = end_fy()) %>%
  mutate(record_keydate2 = record_keydate1)


# Save outfile  ---------------------------------------
outfile <-
  pis_extract %>%
  # sort by chi
  arrange(chi)


# function here till PR pushed
get_year_dir <- function(year, extracts_dir = FALSE) {
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year)

  year_extracts_dir <- fs::path(year_dir, "Extracts")

  return(dplyr::if_else(extracts_dir, year_extracts_dir, year_dir))
}
#

# .zsav
haven::write_sav(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "prescribing_file_for_source-20",
    latest_year, ".zsav"
  ),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "prescribing_file_for_source-20",
    latest_year, ".zsav"
  ),
  compress = "gz"
)



# -------------------------------------------------------------------------------------------

## tests ##

## here till updated version merged
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

create_pis_extract_flags <- function(data) {
  data %>%
    # demog flags
    create_demog_test_flags(postcode = FALSE)
}
##


# flags
pis_flags <- create_pis_extract_flags(outfile)

# summarise values
slf_new <- produce_pis_extract_test(pis_flags)


# -------------------------------------------------------------------------------------------

## episode file ##

episode_file <- read_slf_episode(latest_year,
                                 recid = c("PIS"),
                                 columns = c("recid",
                                             "anon_chi",
                                             "gender",
                                             "dob",
                                             "age",
                                             "hbrescode",
                                             "lca",
                                             "age",
                                             "cost_total_net",
                                             "yearstay",
                                             "stay",
                                             "no_dispensed_items")
)

# anon chi lookup
anonchi_lookup <- haven::read_sav("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav")


episode_file_updated_chi <-
  episode_file %>%
  slfhelper::get_chi()
  select(
    recid,
    chi,
    gender,
    dob,
    age,
    hbrescode,
    no_dispensed_items,
    yearstay,
    stay,
    cost_total_net,
    lca
  )


# flags
episode_flags <- create_pis_extract_flags(episode_file_updated_chi)

# summarise values
slf_existing <- produce_pis_extract_test(episode_flags)


# -------------------------------------------------------------------------------------------

## run comparison function ##

# function here until merged #
extract_comparison_test <- function(slf_new, slf_existing) {

  ## match ##

  comparison <-
    slf_new %>%
    left_join(slf_existing, by = c("measure")) %>%
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
#

comparison <- extract_comparison_test(slf_new = slf_new, slf_existing = slf_existing)


# check if any issues in the comparison
any(comparison$issue == TRUE)


# plot any issues
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
