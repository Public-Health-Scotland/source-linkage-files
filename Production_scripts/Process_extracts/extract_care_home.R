#####################################################
# Care Home
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description -
#####################################################


# Load packages
library(dplyr)
library(dbplyr)
library(createslf)


## Care Home Lookup ##

# Read in data---------------------------------------

ch_lookup <- readxl::read_xlsx(get_slf_ch_path())


# Data Cleaning---------------------------------------

ch_lookup_clean <- ch_lookup %>%
  # correct postcode formatting
  mutate(AccomPostCodeNo = postcode(AccomPostCodeNo)) %>%
  rename(ch_postcode = "AccomPostCodeNo") %>%
  mutate(DateReg = as.Date(DateReg),
         DateCanx = as.Date(DateCanx))


# Care Home names---------------------------------------

name_changes <- ch_lookup_clean %>%
  group_by(ServiceName,
           ch_postcode,
           Council_Area_Name) %>%
  summarise(DateReg = min(DateReg),
            DateCanx = max(DateCanx)) %>%
  # remove any old Care Homes which aren't of interest
  filter(DateReg >= lubridate::ymd("2015-04-01") | DateCanx >= lubridate::ymd("2015-04-01")) %>%
  arrange(ch_postcode, Council_Area_Name, DateReg) %>%
  # when a Care Home changes name mid-year change to the start of the FY
  mutate(year_opened = lubridate::year(DateReg)) %>%
  mutate(change_reg_date = if_else(lubridate::month(DateReg) < 4, 1, 0)) %>%
  mutate(year_opened = if_else(change_reg_date == 1, year_opened - 1, year_opened)) %>%
  mutate(DateReg = if_else(change_reg_date == 1, as.Date(paste0(year_opened, "/04/01")), DateReg)) %>%
  arrange(ch_postcode, Council_Area_Name, desc(DateReg)) %>%
  mutate(change_canx_date = if_else(!is.na(DateCanx) |
                                      (ch_postcode == lag(ch_postcode) &
                                      Council_Area_Name == lag(Council_Area_Name) &
                                      lag(change_reg_date) == 1), 1, 0)) %>%
  mutate(change_canx_date = replace_na(change_canx_date, 0)) %>%
  mutate(DateCanx = if_else(change_canx_date == 1, as.Date(paste0(lubridate::year(DateReg), "/03/31")), DateCanx)) %>%
  arrange(ch_postcode, Council_Area_Name, DateReg)




