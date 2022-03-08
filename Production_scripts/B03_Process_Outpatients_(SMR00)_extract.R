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
  ".csv")
  )  %>%
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
    recid = "00B")


## Recode GP Practice into a 5 digit number ##
# assume that if it starts with a letter it's an English practice and so recode to 99995
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(gpprac = replace(gpprac, substr(gpprac, 1, 1) %in% c("A", "Z"), "99995"))


## compute record key date ##
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(record_keydate2 = record_keydate1)


## Allocate the costs to the correct month ##

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


## outpatient labels ##
outpatient_episode_extract <-
  outpatient_episode_extract %>%
  mutate(
    reftype = factor(reftype,
                     levels = c(1:3),
                     labels = c(
                       "New Outpatient: Consultation and Management",
                       "New Outpatient: Consultation only",
                       "Follow-up/Return Outpatient"
                       )),
    clinic_type = factor(clinic_type,
                         levels = c(1:4),
                         labels = c(
                           "Consultant",
                           "Dentist",
                           "Nurse PIN",
                           "AHP"
                           ))
  )



## save outfile ##
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


## Flags ##
outfile <-
  outfile %>%
  mutate(
    # count CHI
    has_chi = if_else(is.na(chi), 0, 1),
    # count DNA
    dna = if_else(attendance_status == 8, 1, 0),
    # count M/F
    male = if_else(gender == 1, 1, 0),
    female = if_else(gender == 2, 1, 0),
    # count missing values
    no_dob = if_else(is.na(dob), 1, 0),
    # count how many episodes in each HB by treatment code
    nhs_ayrshire_and_arran = if_else(hbtreatcode == 'S08000015', 1, 0),
    nhs_borders = if_else(hbtreatcode == 'S08000016', 1, 0),
    nhs_dumfries_and_galloway = if_else(hbtreatcode == 'S08000017', 1, 0),
    nhs_forth_valley = if_else(hbtreatcode == 'S08000019', 1, 0),
    nhs_grampian = if_else(hbtreatcode == 'S08000020', 1, 0),
    nhs_greater_glasgow_and_clyde = if_else(hbtreatcode %in% c('S08000021', 'S08000031'), 1, 0),
    nhs_highland = if_else(hbtreatcode == 'S08000022', 1, 0),
    nhs_lanarkshire = if_else(hbtreatcode %in% c('S08000023', 'S08000032'), 1, 0),
    nhs_lothian = if_else(hbtreatcode == 'S08000024', 1, 0),
    nhs_orkney = if_else(hbtreatcode == 'S08000025', 1, 0),
    nhs_shetland = if_else(hbtreatcode == 'S08000026', 1, 0),
    nhs_western_isles = if_else(hbtreatcode == 'S08000028', 1, 0),
    nhs_fife = if_else(hbtreatcode %in% c('S08000018', 'S08000029'), 1, 0),
    nhs_tayside = if_else(hbtreatcode %in% c('S08000027', 'S08000030'), 1, 0),
    # change missing HB values
    across(starts_with("nhs_"), ~replace_na(.x, 0)),
    # count HB costs
    nhs_ayrshire_and_arran_cost = if_else(nhs_ayrshire_and_arran == 1, cost_total_net, 0),
    nhs_borders_cost = if_else(nhs_borders == 1, cost_total_net, 0),
    nhs_dumfries_and_galloway_cost = if_else(nhs_dumfries_and_galloway == 1, cost_total_net, 0),
    nhs_forth_valley_cost = if_else(nhs_forth_valley == 1, cost_total_net, 0),
    nhs_grampian_cost = if_else(nhs_grampian == 1, cost_total_net, 0),
    nhs_greater_glasgow_and_clyde_cost = if_else(nhs_greater_glasgow_and_clyde == 1, cost_total_net, 0),
    nhs_highland_cost = if_else(nhs_highland == 1, cost_total_net, 0),
    nhs_lanarkshire_cost = if_else(nhs_lanarkshire == 1, cost_total_net, 0),
    nhs_lothian_cost = if_else(nhs_lothian == 1, cost_total_net, 0),
    nhs_orkney_cost = if_else(nhs_orkney == 1, cost_total_net, 0),
    nhs_shetland_cost = if_else(nhs_shetland == 1, cost_total_net, 0),
    nhs_western_isles_cost = if_else(nhs_western_isles == 1, cost_total_net, 0),
    nhs_fife_cost = if_else(nhs_fife == 1, cost_total_net, 0),
    nhs_tayside_cost = if_else(nhs_tayside == 1, cost_total_net, 0),
    # change missing HB cost values
    across(starts_with("nhs_") & ends_with("_cost"), ~replace_na(.x, 0))
  )


## values for whole file ##
slf_new <-
  outfile %>%
  summarise(
    n_chi = sum(has_chi),
    n_dna = sum(dna),
    n_male = sum(male),
    n_female = sum(female),
    mean_age = mean(age, na.rm = TRUE),
    #n_episodes = n,
    total_cost = sum(cost_total_net, na.rm = TRUE),
    mean_cost = mean(cost_total_net, na.rm = TRUE),
    max_cost = max(cost_total_net, na.rm = TRUE),
    min_cost = min(cost_total_net, na.rm = TRUE),
    earliest_start1 = min(record_keydate1),
    earliest_start2 = min(record_keydate2),
    latest_start1 = max(record_keydate1),
    latest_start2 = max(record_keydate2),
    total_cost_apr = sum(apr_cost, na.rm = TRUE),
    total_cost_may = sum(may_cost, na.rm = TRUE),
    total_cost_jun = sum(jun_cost, na.rm = TRUE),
    total_cost_jul = sum(jul_cost, na.rm = TRUE),
    total_cost_aug = sum(aug_cost, na.rm = TRUE),
    total_cost_sep = sum(sep_cost, na.rm = TRUE),
    total_cost_oct = sum(oct_cost, na.rm = TRUE),
    total_cost_nov = sum(nov_cost, na.rm = TRUE),
    total_cost_dec = sum(dec_cost, na.rm = TRUE),
    total_cost_jan = sum(jan_cost, na.rm = TRUE),
    total_cost_feb = sum(feb_cost, na.rm = TRUE),
    total_cost_mar = sum(mar_cost, na.rm = TRUE),
    mean_cost_apr = mean(apr_cost, na.rm = TRUE),
    mean_cost_may = mean(may_cost, na.rm = TRUE),
    mean_cost_jun = mean(jun_cost, na.rm = TRUE),
    mean_cost_jul = mean(jul_cost, na.rm = TRUE),
    mean_cost_aug = mean(aug_cost, na.rm = TRUE),
    mean_cost_sep = mean(sep_cost, na.rm = TRUE),
    mean_cost_oct = mean(oct_cost, na.rm = TRUE),
    mean_cost_nov = mean(nov_cost, na.rm = TRUE),
    mean_cost_dec = mean(dec_cost, na.rm = TRUE),
    mean_cost_jan = mean(jan_cost, na.rm = TRUE),
    mean_cost_feb = mean(feb_cost, na.rm = TRUE),
    mean_cost_mar = mean(mar_cost, na.rm = TRUE),
    nhs_ayrshire_and_arran = sum(nhs_ayrshire_and_arran),
    nhs_borders = sum(nhs_borders),
    nhs_dumfries_and_galloway = sum(nhs_dumfries_and_galloway),
    nhs_forth_valley = sum(nhs_forth_valley),
    nhs_grampian = sum(nhs_grampian),
    nhs_greater_glasgow_and_clyde = sum(nhs_greater_glasgow_and_clyde),
    nhs_highland = sum(nhs_highland),
    nhs_lanarkshire = sum(nhs_lanarkshire),
    nhs_lothian = sum(nhs_lothian),
    nhs_orkney = sum(nhs_orkney),
    nhs_shetland = sum(nhs_shetland),
    nhs_western_isles = sum(nhs_western_isles),
    nhs_fife = sum(nhs_fife),
    nhs_tayside = sum(nhs_tayside),
    nhs_ayrshire_and_arran_cost = sum(nhs_ayrshire_and_arran_cost),
    nhs_borders_cost = sum(nhs_borders_cost),
    nhs_dumfries_and_galloway_cost = sum(nhs_dumfries_and_galloway_cost),
    nhs_forth_valley_cost = sum(nhs_forth_valley_cost),
    nhs_grampian_cost = sum(nhs_grampian_cost),
    nhs_greater_glasgow_and_clyde_cost = sum(nhs_greater_glasgow_and_clyde_cost),
    nhs_highland_cost = sum(nhs_highland_cost),
    nhs_lanarkshire_cost = sum(nhs_lanarkshire_cost),
    nhs_lothian_cost = sum(nhs_lothian_cost),
    nhs_orkney_cost = sum(nhs_orkney_cost),
    nhs_shetland_cost = sum(nhs_shetland_cost),
    nhs_western_isles_cost = sum(nhs_western_isles_cost),
    nhs_fife_cost = sum(nhs_fife_cost),
    nhs_tayside_cost = sum(nhs_tayside_cost)
  )



# wide to long
slf_new <- as.data.frame(t(slf_new))
slf_new <-
  slf_new %>%
  tibble::rownames_to_column("measure") %>%
  rename(value = "V1")


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
  ))


episode_file <-
  episode_file %>%
  # filter for recid = "00B"
  filter(recid == "00B") %>%
  # rename
  rename(
    chi = "Anon_CHI",
    cost_total_net = "Cost_Total_Net_incDNAs")

## Flags ##
episode_file <-
  episode_file %>%
  mutate(
    # count CHI
    has_chi = if_else(is.na(chi), 0, 1),
    # count DNA
    dna = if_else(attendance_status == 8, 1, 0),
    # count M/F
    male = if_else(gender == 1, 1, 0),
    female = if_else(gender == 2, 1, 0),
    # count missing values
    no_dob = if_else(is.na(dob), 1, 0),
    # count how many episodes in each HB by treatment code
    nhs_ayrshire_and_arran = if_else(hbtreatcode == 'S08000015', 1, 0),
    nhs_borders = if_else(hbtreatcode == 'S08000016', 1, 0),
    nhs_dumfries_and_galloway = if_else(hbtreatcode == 'S08000017', 1, 0),
    nhs_forth_valley = if_else(hbtreatcode == 'S08000019', 1, 0),
    nhs_grampian = if_else(hbtreatcode == 'S08000020', 1, 0),
    nhs_greater_glasgow_and_clyde = if_else(hbtreatcode %in% c('S08000021', 'S08000031'), 1, 0),
    nhs_highland = if_else(hbtreatcode == 'S08000022', 1, 0),
    nhs_lanarkshire = if_else(hbtreatcode %in% c('S08000023', 'S08000032'), 1, 0),
    nhs_lothian = if_else(hbtreatcode == 'S08000024', 1, 0),
    nhs_orkney = if_else(hbtreatcode == 'S08000025', 1, 0),
    nhs_shetland = if_else(hbtreatcode == 'S08000026', 1, 0),
    nhs_western_isles = if_else(hbtreatcode == 'S08000028', 1, 0),
    nhs_fife = if_else(hbtreatcode %in% c('S08000018', 'S08000029'), 1, 0),
    nhs_tayside = if_else(hbtreatcode %in% c('S08000027', 'S08000030'), 1, 0),
    # change missing HB values
    across(starts_with("nhs_"), ~replace_na(.x, 0)),
    # count HB costs
    nhs_ayrshire_and_arran_cost = if_else(nhs_ayrshire_and_arran == 1, cost_total_net, 0),
    nhs_borders_cost = if_else(nhs_borders == 1, cost_total_net, 0),
    nhs_dumfries_and_galloway_cost = if_else(nhs_dumfries_and_galloway == 1, cost_total_net, 0),
    nhs_forth_valley_cost = if_else(nhs_forth_valley == 1, cost_total_net, 0),
    nhs_grampian_cost = if_else(nhs_grampian == 1, cost_total_net, 0),
    nhs_greater_glasgow_and_clyde_cost = if_else(nhs_greater_glasgow_and_clyde == 1, cost_total_net, 0),
    nhs_highland_cost = if_else(nhs_highland == 1, cost_total_net, 0),
    nhs_lanarkshire_cost = if_else(nhs_lanarkshire == 1, cost_total_net, 0),
    nhs_lothian_cost = if_else(nhs_lothian == 1, cost_total_net, 0),
    nhs_orkney_cost = if_else(nhs_orkney == 1, cost_total_net, 0),
    nhs_shetland_cost = if_else(nhs_shetland == 1, cost_total_net, 0),
    nhs_western_isles_cost = if_else(nhs_western_isles == 1, cost_total_net, 0),
    nhs_fife_cost = if_else(nhs_fife == 1, cost_total_net, 0),
    nhs_tayside_cost = if_else(nhs_tayside == 1, cost_total_net, 0),
    # change missing HB cost values
    across(starts_with("nhs_") & ends_with("_cost"), ~replace_na(.x, 0))
  )



## values for whole file ##
slf_existing <-
  episode_file %>%
  summarise(
    n_chi = sum(has_chi),
    n_dna = sum(dna),
    n_male = sum(male),
    n_female = sum(female),
    mean_age = mean(age, na.rm = TRUE),
    #n_episodes = n,
    total_cost = sum(cost_total_net, na.rm = TRUE),
    mean_cost = mean(cost_total_net, na.rm = TRUE),
    max_cost = max(cost_total_net, na.rm = TRUE),
    min_cost = min(cost_total_net, na.rm = TRUE),
    earliest_start1 = min(record_keydate1),
    earliest_start2 = min(record_keydate2),
    latest_start1 = max(record_keydate1),
    latest_start2 = max(record_keydate2),
    total_cost_apr = sum(apr_cost, na.rm = TRUE),
    total_cost_may = sum(may_cost, na.rm = TRUE),
    total_cost_jun = sum(jun_cost, na.rm = TRUE),
    total_cost_jul = sum(jul_cost, na.rm = TRUE),
    total_cost_aug = sum(aug_cost, na.rm = TRUE),
    total_cost_sep = sum(sep_cost, na.rm = TRUE),
    total_cost_oct = sum(oct_cost, na.rm = TRUE),
    total_cost_nov = sum(nov_cost, na.rm = TRUE),
    total_cost_dec = sum(dec_cost, na.rm = TRUE),
    total_cost_jan = sum(jan_cost, na.rm = TRUE),
    total_cost_feb = sum(feb_cost, na.rm = TRUE),
    total_cost_mar = sum(mar_cost, na.rm = TRUE),
    mean_cost_apr = mean(apr_cost, na.rm = TRUE),
    mean_cost_may = mean(may_cost, na.rm = TRUE),
    mean_cost_jun = mean(jun_cost, na.rm = TRUE),
    mean_cost_jul = mean(jul_cost, na.rm = TRUE),
    mean_cost_aug = mean(aug_cost, na.rm = TRUE),
    mean_cost_sep = mean(sep_cost, na.rm = TRUE),
    mean_cost_oct = mean(oct_cost, na.rm = TRUE),
    mean_cost_nov = mean(nov_cost, na.rm = TRUE),
    mean_cost_dec = mean(dec_cost, na.rm = TRUE),
    mean_cost_jan = mean(jan_cost, na.rm = TRUE),
    mean_cost_feb = mean(feb_cost, na.rm = TRUE),
    mean_cost_mar = mean(mar_cost, na.rm = TRUE),
    nhs_ayrshire_and_arran = sum(nhs_ayrshire_and_arran),
    nhs_borders = sum(nhs_borders),
    nhs_dumfries_and_galloway = sum(nhs_dumfries_and_galloway),
    nhs_forth_valley = sum(nhs_forth_valley),
    nhs_grampian = sum(nhs_grampian),
    nhs_greater_glasgow_and_clyde = sum(nhs_greater_glasgow_and_clyde),
    nhs_highland = sum(nhs_highland),
    nhs_lanarkshire = sum(nhs_lanarkshire),
    nhs_lothian = sum(nhs_lothian),
    nhs_orkney = sum(nhs_orkney),
    nhs_shetland = sum(nhs_shetland),
    nhs_western_isles = sum(nhs_western_isles),
    nhs_fife = sum(nhs_fife),
    nhs_tayside = sum(nhs_tayside),
    nhs_ayrshire_and_arran_cost = sum(nhs_ayrshire_and_arran_cost),
    nhs_borders_cost = sum(nhs_borders_cost),
    nhs_dumfries_and_galloway_cost = sum(nhs_dumfries_and_galloway_cost),
    nhs_forth_valley_cost = sum(nhs_forth_valley_cost),
    nhs_grampian_cost = sum(nhs_grampian_cost),
    nhs_greater_glasgow_and_clyde_cost = sum(nhs_greater_glasgow_and_clyde_cost),
    nhs_highland_cost = sum(nhs_highland_cost),
    nhs_lanarkshire_cost = sum(nhs_lanarkshire_cost),
    nhs_lothian_cost = sum(nhs_lothian_cost),
    nhs_orkney_cost = sum(nhs_orkney_cost),
    nhs_shetland_cost = sum(nhs_shetland_cost),
    nhs_western_isles_cost = sum(nhs_western_isles_cost),
    nhs_fife_cost = sum(nhs_fife_cost),
    nhs_tayside_cost = sum(nhs_tayside_cost)
  )


# wide to long
slf_existing <- as.data.frame(t(slf_existing))
slf_existing <-
  slf_existing %>%
  tibble::rownames_to_column("measure") %>%
  rename(value = "V1")



# -------------------------------------------------------------------------------------------


## match ##

outpatient_comparison <-
  slf_new %>%
  full_join(slf_existing, by = c("measure")) %>%
  # rename
  rename(new_value = "value.x",
         existing_value = "value.y") %>%
  mutate(new_value = as.numeric(new_value),
         existing_value = as.numeric(existing_value))


## comparison ##

outpatient_comparison <-
  outpatient_comparison %>%
  mutate(difference = new_value - existing_value) %>%
  mutate(pct_change = difference / existing_value * 100) %>%
  mutate(issue = abs(pct_change) > 5)


# plot issues
outpatient_comparison %>%
  filter(issue == TRUE) %>%
  ggplot(aes(x = measure, y = difference)) +
  geom_bar(stat="identity", fill="steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

outpatient_comparison %>%
  filter(issue == TRUE) %>%
  ggplot(aes(x = measure, y = pct_change)) +
  geom_bar(stat="identity", fill="steelblue") +
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

