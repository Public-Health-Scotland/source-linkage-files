#####################################################
# A&E Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process A & E extract
#####################################################

# Load packages
library(dplyr)
library(tidyr)
library(readr)
library(createslf)


# Read in data---------------------------------------

# Specify year
year <- check_year_format("1920")

ae_file <- readr::read_csv(
  file = get_boxi_extract_path(year, "AE"),
  col_type = cols(
    `Arrival Date` = col_date(format = "%Y/%m/%d %T"),
    `DAT Date` = col_date(format = "%Y/%m/%d %T"),
    `Pat UPI [C]` = col_character(),
    `Pat Date Of Birth [C]` = col_date(format = "%Y/%m/%d %T"),
    `Pat Gender Code` = col_double(),
    `NHS Board of Residence Code - current` = col_character(),
    `Treatment NHS Board Code - current` = col_character(),
    `Treatment Location Code` = col_character(),
    `GP Practice Code` = col_character(),
    `Council Area Code` = col_character(),
    `Postcode (epi) [C]` = col_character(),
    `Postcode (CHI) [C]` = col_character(),
    `HSCP of Residence Code - current` = col_character(),
    `Arrival Time` = col_time(""),
    `DAT Time` = col_time(""),
    `Arrival Mode Code` = col_character(),
    `Referral Source Code` = col_character(),
    `Attendance Category Code` = col_character(),
    `Discharge Destination Code` = col_character(),
    `Patient Flow Code` = col_double(),
    `Place of Incident Code` = col_character(),
    `Reason for Wait Code` = col_character(),
    `Disease 1 Code` = col_character(),
    `Disease 2 Code` = col_character(),
    `Disease 3 Code` = col_character(),
    `Bodily Location Of Injury Code` = col_character(),
    `Alcohol Involved Code` = col_character(),
    `Alcohol Related Admission` = col_character(),
    `Substance Misuse Related Admission` = col_character(),
    `Falls Related Admission` = col_character(),
    `Self Harm Related Admission` = col_character(),
    `Total Net Costs` = col_double(),
    `Age at Midpoint of Financial Year` = col_double(),
    `Case Reference Number` = col_character(),
    `Significant Facility Code` = col_double()
  )
) %>%
  # rename variables
  rename(
    record_keydate1 = "Arrival Date",
    record_keydate2 = "DAT Date",
    dob = "Pat Date Of Birth [C]",
    postcode_epi = "Postcode (epi) [C]",
    postcode_chi = "Postcode (CHI) [C]",
    age = "Age at Midpoint of Financial Year",
    ae_alcohol = "Alcohol Involved Code",
    alcohol_adm = "Alcohol Related Admission",
    ae_arrivalmode = "Arrival Mode Code",
    keyTime1 = "Arrival Time",
    ae_attendcat = "Attendance Category Code",
    ae_bodyloc = "Bodily Location Of Injury Code",
    lca = "Council Area Code",
    ae_disdest = "Discharge Destination Code",
    keyTime2 = "DAT Time",
    diag1 = "Disease 1 Code",
    diag2 = "Disease 2 Code",
    diag3 = "Disease 3 Code",
    falls_adm = "Falls Related Admission",
    gpprac = "GP Practice Code",
    hscp = "HSCP of Residence Code - current",
    hbrescode = "NHS Board of Residence Code - current",
    hbtreatcode = "Treatment NHS Board Code - current",
    chi = "Pat UPI [C]",
    gender = "Pat Gender Code",
    ae_patflow = "Patient Flow Code",
    ae_placeinc = "Place of Incident Code",
    ae_reasonwait = "Reason for Wait Code",
    refsource = "Referral Source Code",
    selfharm_adm = "Self Harm Related Admission",
    submis_adm = "Substance Misuse Related Admission",
    sigfac = "Significant Facility Code",
    cost_total_net = "Total Net Costs",
    location = "Treatment Location Code",
    case_ref_number = "Case Reference Number"
  )


# Data Cleaning -----------------------------------------

ae_clean <- ae_file %>%
  # year variable
  mutate(
    year = year,
    recid = "AE2"
  ) %>%
  ## Recode GP Practice into a 5 digit number ##
  # assume that if it starts with a letter it's an English practice and so recode to 99995
  convert_eng_gpprac_to_dummy(gpprac) %>%
  # use the CHI postcode and if that is blank, then use the epi postcode.
  mutate(postcode = if_else(!is.na(postcode_chi), postcode_chi, postcode_epi)) %>%
  ## recode cypher HB codes ##
  mutate(across(c(hbtreatcode, hbrescode), ~ case_when(
    .x == "A" ~ "S08000015",
    .x == "B" ~ "S08000016",
    .x == "F" ~ "S08000029",
    .x == "G" ~ "S08000021",
    .x == "H" ~ "S08000022",
    .x == "L" ~ "S08000023",
    .x == "N" ~ "S08000020",
    .x == "R" ~ "S08000025",
    .x == "S" ~ "S08000024",
    .x == "T" ~ "S08000030",
    .x == "V" ~ "S08000019",
    .x == "W" ~ "S08000028",
    .x == "Y" ~ "S08000017",
    .x == "Z" ~ "S08000026"
  ))) %>%
  ## Allocate the costs to the correct month ##
  # Create month and SMR type variables
  mutate(month = strftime(record_keydate1, "%m"),
         smrtype = add_smr_type(recid)) %>%
  # Allocate the costs to the correct month
  create_day_episode_costs(record_keydate1, cost_total_net)

# Factors ---------------------------------------------------

ae_clean <- ae_clean %>%
  mutate(
    ae_arrivalmode = factor(ae_arrivalmode,
      levels = c("01", "02", "03", "04", "05", "06", "07", "08", "98", "99")
    ),
    ae_attendcat = factor(ae_attendcat,
      levels = c("01", "02", "03", "04")
    ),
    ae_disdest = factor(ae_disdest,
      levels = c(
        "00",
        "01", "01A", "01B",
        "02", "02A", "02B",
        "03", "03A", "03B", "03C", "03D", "03Z",
        "04", "04A", "04B", "04C", "04D", "04Z",
        "05", "05A", "05B", "05C", "05D", "05E", "05F", "05G", "05H", "05Z",
        "06",
        "98",
        "99"
      )
    ),
    ae_patflow = factor(ae_patflow, levels = c(1:5)),
    ae_placeinc = factor(ae_placeinc,
      levels = c(
        "01", "01A", "01B",
        "02", "02A", "02B",
        "03", "03A", "03B", "03C",
        "04",
        "05", "05A", "05B", "05C",
        "06",
        "98",
        "99"
      )
    ),
    ae_reasonwait = factor(ae_reasonwait,
      levels = c(
        "00",
        "01",
        "02",
        "03", "03A", "03B",
        "05", "05A", "05B",
        "06",
        "07",
        "98"
      )
    ),
    ae_alcohol = factor(ae_alcohol, levels = c(1:2)),
    ae_bodyloc = factor(ae_bodyloc,
      levels = c(
        "00",
        "01", "01A", "01B", "01C", "01D", "01Z",
        "02", "02A", "02B", "02C", "02D", "02E", "02F", "02Z",
        "03", "03A", "03B", "03C", "03D", "03E", "03F", "03G", "03H", "03Z",
        "04", "04A", "04B", "04C", "04D", "04E", "04F", "04G", "04H", "04Z",
        "05", "05A", "05B", "05C", "05D", "05F", "05Z",
        "06", "06A", "06B", "06C", "06D", "06E", "06F", "06Z",
        "07", "07A", "07B", "07C", "07D", "07E", "07F", "07G", "07H", "07J", "07Z",
        "08", "08A", "08B", "08C", "08D", "08E", "08F", "08G", "08Z",
        "09", "09A", "09B", "09C", "09D", "09E", "09F", "09G", "09H", "09J", "09K", "09L", "09M", "09N", "09P", "09Q", "09Z",
        "10", "10A", "10B", "10C", "10D", "10E",
        "11", "11A", "11B", "11C", "11D", "11E", "11Z",
        "12", "12A", "12B", "12C", "12D", "12E", "12F", "12G", "12Z",
        "13", "13A", "13B",
        "14", "14A", "14B", "14C", "14D", "14E", "14F", "14G", "14H", "14Z",
        "15", "15A", "15B", "15C", "15D", "15E", "15F", "15G", "15H", "15J", "15K", "15L", "15M", "15N", "15Z",
        "16", "16A", "16B", "16C", "16Z",
        "17", "17A", "17B", "17C", "17D", "17E", "17F", "17G", "17H", "17Z",
        "18", "18A", "18B", "18C", "18D", "18E", "18F", "18G", "18H", "18J", "18K", "18L", "18Z",
        "19", "19A", "19B", "19C", "19D", "19E", "19F", "19G", "19Z",
        "20", "20A", "20B", "20C", "20D", "20E", "20F", "20G", "20H", "20J", "20K", "20L", "20M", "20Z",
        "21", "21A", "21B", "21C", "21D", "21E", "21F", "21G", "21H", "21J", "21Z",
        "22", "22A", "22B", "22C", "22D", "22E", "22F", "22G", "22H", "22J", "22K",
        "23", "23A", "23B", "23C", "23D", "23E", "23F",
        "24", "24A", "24B", "24C", "24D",
        "25", "25A", "25B", "25C", "25D", "25E", "25F", "25Z",
        "26", "26A", "26B", "26C", "26D", "26E", "26F", "26G", "26H", "26J", "26K", "26L", "26M", "26Z",
        "27", "27A", "27B", "27C", "27D", "27E", "27F", "27G", "27H", "27Z",
        "28", "28A", "28B", "28C", "28D", "28E", "28F", "28Z",
        "29", "29A", "29B", "29C", "29D", "29E", "29F", "29G", "29H", "29J", "29K", "29L", "29M", "29N",
        "30", "30A", "30B", "30C", "30D", "30E",
        "31"
      )
    )
  )

## save outfile ---------------------------------------
outfile <-
  ae_clean %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    keyTime1,
    keyTime2,
    smrtype,
    chi,
    gender,
    dob,
    gpprac,
    postcode,
    lca,
    hscp,
    location,
    hbrescode,
    hbtreatcode,
    starts_with("diag"),
    refsource,
    sigfac,
    starts_with("ae_"),
    ends_with("_adm"),
    cost_total_net,
    age,
    ends_with("_cost"),
    case_ref_number
  )


# ------------------------------------------------------------------------------------------------------------

## CUP Marker ##

# Read in data---------------------------------------

ae_cup_file <- readr::read_csv(
  file = get_boxi_extract_path(year, "AE_CUP"),
  col_type = cols(
    `ED Arrival Date` = col_date(format = "%Y/%m/%d %T"),
    `ED Arrival Time` = col_time(""),
    `ED Case Reference Number [C]` = col_character(),
    `CUP Marker` = col_double(),
    `CUP Pathway Name` = col_character()
  )
) %>%
  # rename variables
  rename(
    record_keydate1 = "ED Arrival Date",
    keyTime1 = "ED Arrival Time",
    case_ref_number = "ED Case Reference Number [C]",
    cup_marker = "CUP Marker",
    cup_pathway = "CUP Pathway Name"
  )


# Data Cleaning---------------------------------------

ae_cup_clean <- ae_cup_file %>%
  # Remove any duplicates
  distinct(record_keydate1,
    keyTime1,
    case_ref_number,
    .keep_all = TRUE
  )


# Join data--------------------------------------------

matched_ae_data <- outfile %>%
  left_join(ae_cup_clean, by = c("record_keydate1", "keyTime1", "case_ref_number")) %>%
  arrange(chi, record_keydate1, keyTime1, record_keydate2, keyTime2)


# Save outfile----------------------------------------
outfile <- matched_ae_data %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    keyTime1,
    keyTime2,
    smrtype,
    chi,
    gender,
    dob,
    gpprac,
    postcode,
    lca,
    hscp,
    location,
    hbrescode,
    hbtreatcode,
    diag1,
    diag2,
    diag3,
    ae_arrivalmode,
    refsource,
    sigfac,
    ae_attendcat,
    ae_disdest,
    ae_patflow,
    ae_placeinc,
    ae_reasonwait,
    ae_bodyloc,
    ae_alcohol,
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    cost_total_net,
    age,
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
    cup_marker,
    cup_pathway
  )

# Save as zsav file
outfile %>%
  write_sav(get_source_extract_path(year, "AE", ext = "zsav", check_mode = "write")) %>%
  # Save as rds file
  write_rds(get_source_extract_path(year, "AE", check_mode = "write"))


# End of Script #
