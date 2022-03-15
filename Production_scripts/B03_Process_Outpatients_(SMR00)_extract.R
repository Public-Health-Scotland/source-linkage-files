#####################################################
# Outpatient Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input - episode extract csv file
# Description - Process Outpatients extract
#####################################################


library(dplyr)
library(purrr)
library(vroom)
library(tidyr)
library(ggplot2)


## Read in CSV output file ##

# latest year
latest_year <- 1920

# function here till PR pushed
get_year_dir <- function(year, extracts_dir = FALSE) {
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year)

  year_extracts_dir <- fs::path(year_dir, "Extracts")

  return(dplyr::if_else(extracts_dir, year_extracts_dir, year_dir))
}


outpatient_episode_extract <- readr::read_csv(
  paste0(
    get_year_dir(year = latest_year),
    "/Extracts/Outpatients-episode-level-extract-",
    paste0(convert_fyyear_to_year(latest_year), substr(latest_year, 3, 4)),
    ".csv"
  )
) %>%
  # rename
  rename(
    clinic_date_fy = "Clinic Date Fin Year",
    record_keydate1 = "Clinic Date (00)",
    dob = "Pat Date Of Birth [C]",
    age = "Age at Midpoint of Financial Year",
    alcohol_adm = "Alcohol Related Admission",
    attendance_status = "Clinic Attendance (Status) Code",
    clinic_type = "Clinic Type Code",
    commhosp = "Community Hospital Flag",
    conc = "Consultant/HCP Code",
    uri = "Episode Record Key (SMR00) [C]",
    falls_adm = "Falls Related Admission",
    lca = "Geo Council Area Code",
    postcode = "Geo Postcode [C]",
    hbrescode = "NHS Board of Residence Code - current",
    nhshosp = "NHS Hospital Flag",
    op1a = "Operation 1A Code (4 char)",
    op1b = "Operation 1B Code (4 char)",
    dateop1 = "Date of Main Operation(00)",
    op2a = "Operation 2A Code (4 char)",
    op2b = "Operation 2B Code (4 char)",
    dateop2 = "Date of Operation 2 (00)",
    gender = "Pat Gender Code",
    chi = "Pat UPI",
    cat = "Patient Category Code",
    gpprac = "Practice Location Code",
    hbpraccode = "Practice NHS Board Code - current",
    refsource = "Referral Source Code",
    reftype = "Referral Type Code",
    selfharm_adm = "Self Harm Related Admission",
    sigfac = "Significant Facility Code",
    spec = "Specialty Classificat. 1/4/97 Code",
    submis_adm = "Substance Misuse Related Admission",
    cost_total_net = "Total Net Costs",
    location = "Treatment Location Code",
    hbtreatcode = "Treatment NHS Board Code - current"
  ) %>%
  # date types
  mutate(
    dob = as.Date(dob),
    dateop1 = as.Date(dateop1),
    dateop2 = as.Date(dateop2),
    record_keydate1 = as.Date(record_keydate1)
  )


# year variable
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(
    year = latest_year,
    recid = "00B"
  )


## Recode GP Practice into a 5 digit number ---------------------------------------
# assume that if it starts with a letter it's an English practice and so recode to 99995
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(gpprac = replace(gpprac, substr(gpprac, 1, 1) %in% c("A", "Z"), "99995"))


## compute record key date ##
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(record_keydate2 = record_keydate1)


## Allocate the costs to the correct month ---------------------------------------

# month and month_cost variable
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(month = strftime(record_keydate1, "%m"))


# cost in correct month
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(
    apr_cost = if_else(month == "04", cost_total_net, 0),
    may_cost = if_else(month == "05", cost_total_net, 0),
    jun_cost = if_else(month == "06", cost_total_net, 0),
    jul_cost = if_else(month == "07", cost_total_net, 0),
    aug_cost = if_else(month == "08", cost_total_net, 0),
    sep_cost = if_else(month == "09", cost_total_net, 0),
    oct_cost = if_else(month == "10", cost_total_net, 0),
    nov_cost = if_else(month == "11", cost_total_net, 0),
    dec_cost = if_else(month == "12", cost_total_net, 0),
    jan_cost = if_else(month == "01", cost_total_net, 0),
    feb_cost = if_else(month == "02", cost_total_net, 0),
    mar_cost = if_else(month == "03", cost_total_net, 0)
  )


# sort by chi record_keydate1
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  arrange(chi, record_keydate1)


## outpatient labels ---------------------------------------
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(
    reftype = factor(reftype,
      levels = c(1:3),
      labels = c(
        "New Outpatient: Consultation and Management",
        "New Outpatient: Consultation only",
        "Follow-up/Return Outpatient"
      )
    ),
    clinic_type = factor(clinic_type,
      levels = c(1:4),
      labels = c(
        "Consultant",
        "Dentist",
        "Nurse PIN",
        "AHP"
      )
    )
  )



## save outfile ---------------------------------------
outfile <-
  outpatient_episode_extract %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    chi,
    gender,
    dob,
    gpprac,
    hbpraccode,
    postcode,
    hbrescode,
    lca,
    location,
    hbtreatcode,
    op1a,
    op1b,
    dateop1,
    op2a,
    op2b,
    dateop2,
    spec,
    sigfac,
    conc,
    cat,
    age,
    refsource,
    reftype,
    attendance_status,
    clinic_type,
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    commhosp,
    nhshosp,
    cost_total_net,
    apr_cost,
    may_cost,
    jun_cost,
    jul_cost,
    aug_cost,
    sep_cost,
    oct_cost,
    nov_cost,
    dec_cost,
    jan_cost,
    feb_cost,
    mar_cost,
    uri
  )

# .zsav
haven::write_sav(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "/outpatient_for_source-20",
    latest_year, ".zsav"
  ),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "/outpatient_for_source-20",
    latest_year, ".zsav"
  ),
  compress = "gz"
)


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
##

## Flags ##
outpatient_flags <- create_outpatient_extract_flags(outfile, postcode = FALSE)


## values for whole file ##
slf_new <- produce_outpatient_extract_test(outpatient_flags)


# -------------------------------------------------------------------------------------------


## get data ##

episode_file <- haven::read_sav(
  paste0("/conf/hscdiip/01-Source-linkage-files/source-episode-file-20", latest_year, ".zsav"),
  col_select = c(
    recid,
    Anon_CHI,
    record_keydate1,
    record_keydate2,
    gender,
    dob,
    age,
    hbtreatcode,
    Cost_Total_Net_incDNAs,
    apr_cost,
    may_cost,
    jun_cost,
    jul_cost,
    aug_cost,
    sep_cost,
    oct_cost,
    nov_cost,
    dec_cost,
    jan_cost,
    feb_cost,
    mar_cost,
    attendance_status
  )
)


episode_file <-
  episode_file %>%
  # filter for recid = "00B"
  filter(recid == "00B") %>%
  # rename
  rename(
    chi = "Anon_CHI",
    cost_total_net = "Cost_Total_Net_incDNAs"
  )


## Flags ##
episode_flags <- create_outpatient_extract_flags(episode_file, postcode = FALSE)


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
    mutate(pct_change = difference / existing_value * 100) %>%
    mutate(issue = abs(pct_change) > 5)
}

## run comparison function
comparison <- extract_comparison_test(slf_new = slf_new, slf_existing = slf_existing)


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
