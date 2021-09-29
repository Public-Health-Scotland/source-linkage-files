library(labelled)
library(tidyverse)
library(slfhelper)
library(ggplot2)
library(phsmethods)
library(dplyr)
hscp_lookup <- slfhelper::partnerships

#Ideas for cross year testing SLFs, can display this as ggplots or tables?
  # Compare total cost by year, spec and recid 
  # Compare admissions by year and hscp 
  # Compare total number of patients across year and hscp
  # Compare beddays/cost per year/hscp
  # Compare health board 
  # Compare across Recid, percentages/rates? 
  # Compare admissions broken down by year/sex 
  # number episodes across years per recid 
  # episodes per person across recid per year
  # split by age group, gender, simd, sig fac,locations 
  # avg cost per day across recid


###############
#Read in SLFs across years
data <- read_slf_episode(year = c("1516", "1617", "1718", "1819", "1920"),
                         columns = c("year", "recid", "anon_chi", "hscp2019", "hbtreatcode", "hb2019",
                                     "gender", "spec", "age", "cost_total_net", "yearstay", 
                                     "sigfac", "simd2020v2_sc_quintile", "tadm", "location"))

# Create some age groups
data <- data %>% 
  mutate(Age_group = case_when(
    age < 20 ~ "<20",
    between(age, 20, 29) ~ "20-29",
    between(age, 30, 39) ~ "30-39",
    between(age, 40, 49) ~ "40-49", 
    between(age, 50, 59) ~ "50-59", 
    between(age, 60, 69) ~ "60-69",
    between(age, 70, 79) ~ "70-79", 
    between(age, 80, 89) ~ "80-89", 
    age >90 ~ ">90"))

# Use labels 
data <- data %>% 
  get_labels(hbtreatcode)


#' Convert HB2019 codes to factors with names as labels
#'
#' @param HB2019
#'
#' @return
#' @export
#'
#' @examples

hb_2019_as_factor <- function(HB2019) {
  factor(
    HB2019,
    levels = c(
      "S08000015",
      "S08000016",
      "S08000017",
      "S08000019",
      "S08000020",
      "S08000031",
      "S08000022",
      "S08000032",
      "S08000024",
      "S08000025",
      "S08000026",
      "S08000028",
      "S08000029",
      "S08000030"
    ),
    labels = c(
      "Ayrshire and Arran",
      "Borders",
      "Dumfries and Galloway",
      "Forth Valley",
      "Grampian",
      "Greater Glasgow and Clyde",
      "Highland",
      "Lanarkshire",
      "Lothian",
      "Orkney",
      "Shetland",
      "Western Isles",
      "Fife",
      "Tayside"
    )
  )
}

#' Convert HSCP2019 codes to factors with names as labels
#'
#' @param HSCP2019
#'
#' @return
#' @export
#'
#' @examples
hscp_2019_as_factor <- function(HSCP2019) {
  factor(
    HSCP2019,
    levels = c(
      "S37000001",
      "S37000002",
      "S37000003",
      "S37000004",
      "S37000005",
      "S37000006",
      "S37000007",
      "S37000008",
      "S37000009",
      "S37000010",
      "S37000011",
      "S37000012",
      "S37000013",
      "S37000034",
      "S37000016",
      "S37000017",
      "S37000018",
      "S37000019",
      "S37000020",
      "S37000035",
      "S37000022",
      "S37000024",
      "S37000025",
      "S37000026",
      "S37000027",
      "S37000028",
      "S37000029",
      "S37000030",
      "S37000031",
      "S37000032",
      "S37000033"
    ),
    labels = c(
      "Aberdeen City",
      "Aberdeenshire",
      "Angus",
      "Argyll and Bute",
      "Clackmannanshire and Stirling",
      "Dumfries and Galloway",
      "Dundee City",
      "East Ayrshire",
      "East Dunbartonshire",
      "East Lothian",
      "East Renfrewshire",
      "Edinburgh",
      "Falkirk",
      "Glasgow City",
      "Highland",
      "Inverclyde",
      "Midlothian",
      "Moray",
      "North Ayrshire",
      "North Lanarkshire",
      "Orkney Islands",
      "Renfrewshire",
      "Scottish Borders",
      "Shetland Islands",
      "South Ayrshire",
      "South Lanarkshire",
      "West Dunbartonshire",
      "West Lothian",
      "Western Isles",
      "Fife",
      "Perth and Kinross"
    )
  )
}


###############
#ADMISSIONS 
###############

# Get total admissions by hscp
hscpadmissions <- data %>%
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year, hscp2019) %>%
  summarise(admissions = n()) %>% 
  filter(hscp2019 != "") %>% 
  ungroup()

hscpadmissions %>%
  ggplot(aes(x = year, y = admissions, fill = hscp_2019_as_factor(hscp2019))) +
  geom_col(position = "dodge")+
  labs(x = "Year", y = "Total Number of Admissions", fill = "Health & Social Care Partnership")

#show any interesting changes across years
hscpadmissions_diff <- hscpadmissions %>%
  pivot_wider(
    names_from = "year",
    values_from = c("admissions"),
    names_prefix = "total"
  ) %>%
  mutate(
    diff_1516_1617 = (total1617 - total1516) / total1516 * 100,
    diff_1617_1718 = (total1718 - total1617) / total1617 * 100,
    diff_1718_1819 = (total1819 - total1718) / total1718 * 100,
    diff_1819_1920 = (total1920 - total1819) / total1819 * 100
  ) %>%
  rowwise() %>%
  mutate(issue = if_else(any(
    abs(diff_1516_1617) >= 10,
    abs(diff_1617_1718) >= 10,
    abs(diff_1718_1819) >= 10,
    abs(diff_1819_1920) >= 10
  ), 1L, 0L)) %>% 
  ungroup() %>% 
filter(issue == 1) 

filter_issues <- function(data, value_var) {
  data %>%
    pivot_wider(
      names_from = year,
      values_from = {{value_var}},
      names_prefix = "total"
    ) %>%
    mutate(
      diff_1516_1617 = (total1617 - total1516) / total1516 * 100,
      diff_1617_1718 = (total1718 - total1617) / total1617 * 100,
      diff_1718_1819 = (total1819 - total1718) / total1718 * 100,
      diff_1819_1920 = (total1920 - total1819) / total1819 * 100
    ) %>%
    rowwise() %>%
    mutate(issue = if_else(any(
      abs(diff_1516_1617) >= 10,
      abs(diff_1617_1718) >= 10,
      abs(diff_1718_1819) >= 10,
      abs(diff_1819_1920) >= 10
    ), 1L, 0L)) %>% 
    ungroup() %>% 
    filter(issue == 1)
}


hscpadmissions %>% 
  filter_issues(admissions)


hscp_pivot <- hscpadmissions_diff %>%
  select(-diff_1516_1617:-diff_1819_1920) %>% 
  pivot_longer(
    cols = starts_with("total"),
    names_to = c("year"),
    values_to = c("admissions")
  )

#bar graph with partnerships with +-10% change at any point
hscp_pivot %>%
  ggplot(aes(x = year, y = admissions, fill = hscp_2019_as_factor(hscp2019))) +
  geom_col(position = "dodge")+
  labs(x = "Year", y = "Total Number of Admissions", fill = "Health & Social Care Partnership")

#Line graph with partnerships with +-10% change at any point 
hscp_pivot %>% 
ggplot(aes(x = as.integer(as.ordered(year)), y = admissions, colour = hscp_2019_as_factor(hscp2019))) +
  geom_line()+
  scale_x_continuous("year", labels = levels(as.ordered(hscp_pivot$year)))+
  labs(x = "Year", y = "Total Number of Admissions", colour = "Health & Social Care Partnership")


###
  # Compare admissions by Health Board of residence per year
hbadmissions <- data %>%
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year, hb2019) %>%
  summarise(admissions = n()) %>%
  ungroup()%>% 
  filter(hb2019 != "") 


hbadmissions %>% 
  filter_issues(admissions)

hbadmissionstest <- hbadmissions %>% 
  mutate()

hbadmissions %>% 
  ggplot(aes(x = year, y = admissions, fill = hb_2019_as_factor(hb2019))) +
  geom_col(position = "dodge") +
  labs(x = "Year", y = "Total Number of Admissions", fill = "Health Board")






###
  # Compare admissions by year and spec 
spec_admissions <- data %>%
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year, spec) %>%
  summarise(admissions = n()) %>% 
  ungroup()

spec_admissions %>% 
  ggplot(aes(x = year, y = admissions, fill = spec)) +
  geom_col(position = "dodge") +
  labs(x = "year", y = "Total Number of Admissions", fill = "Specialty")

spec_admissions %>% 
  ggplot(aes(x = as.integer(as.ordered(year)), y = admissions, colour = as.factor(spec)))  +
  geom_line() +
  scale_x_continuous("year", labels = levels(as.ordered(spec_admissions$year))) +
  labs(x = "Year", y = "Total Number of Admissions") + 
  scale_colour_discrete(name = "spec")


###
  # Number of episodes per year across recid 
recid_eps <- data %>% 
  group_by(year, recid) %>% 
  summarise(total_eps = n()) %>% 
  ungroup()

recid_eps %>% 
  ggplot(aes(x = year, y = total_eps, fill = recid)) +
  geom_col(position = "dodge")

recid_eps %>% 
  ggplot(aes(x = as.integer(as.ordered(year)), y = total_eps, colour = as.factor(recid))) +
  geom_line()+
  scale_x_continuous("year", labels = levels(as.ordered(recid_eps$year)))


###
# Compare percentage of emergency admissions across years 
emergency_adm <- data %>% 
  filter(recid %in% c("01B", "GLS")) %>%
  filter(tadm %in% c(30, 31, 32, 33, 34, 35, 36, 38, 39)) %>% 
  group_by(year) %>% 
  summarise(emergency_adm = n()) %>% 
  ungroup()
  
adm <- data %>% 
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year) %>% 
  summarise(admissions = n()) %>% 
  ungroup()

#merge datasets to work out percentage of emergency admissions 
tadm <- merge(x= emergency_adm, y= adm, by = "year")

tadm <- tadm %>% 
  mutate(percentage = (admissions - emergency_adm)/admissions * 100) %>% 
  mutate(cruderate = (emergency_adm/admissions)*1000)


#create a plot 
tadm %>% 
  ggplot(aes(x = as.integer(as.ordered(year)), y = cruderate)) +
  geom_line()+
  scale_x_continuous("year", labels = levels(as.ordered(tadm$year))) + 
  labs(x = "Year", y = "Total number of emergency admissions per 1,000")

tadm %>% 
  ggplot(aes(x = year, y = percentage)) +
  geom_col(position = "dodge")



###############
#PATIENTS 
###############

###
  # Get total number of patients per year and hscp
patients_by_hscp <- data %>% 
  filter(recid %in% c("01B", "GLS")) %>%
  filter(anon_chi != "",
         hb2019 != "") %>% 
  distinct(year, hscp2019, anon_chi) %>% 
  count(year, hscp2019) %>% 
  ungroup()

  #create a plot
patients_by_hscp %>%  
  ggplot(aes(x = year, y = n, fill = hscp_2019_as_factor(hscp2019))) +
  geom_col(position = "dodge")+
  labs(x = "Year", y = "Total Number of patients", fill = "Health & Social Care Partnership")


###
  #Get total number of patients per year and health board 
patients_by_hb <- data %>% 
  filter(recid %in% c("01B", "GLS")) %>%
  filter(anon_chi != "",
         hb2019 != "") %>% 
  distinct(year, hb2019, anon_chi) %>% 
  count(year, hb2019) %>% 
  ungroup()
  
####
#could also write this as the following
  #group_by(year, hb2019) %>% 
  #summarise(patients = n_distinct(anon_chi)) %>% 
  #ungroup()

patients_by_hb %>%  
  ggplot(aes(x = year, y = n, fill = hb_2019_as_factor(hb2019))) +
  geom_col(position = "dodge")+
  labs(x = "Year", y = "Total Number of patients", fill = "Health Board")



###
  # Patients by recid 
patients_by_recid <- data %>%
  filter(
    anon_chi != "",
    hb2019 != ""
  ) %>%
  distinct(year, recid, anon_chi) %>%
  count(year, recid) %>%
  ungroup()
  
  # Create a plot 
patients_by_recid %>%  
  ggplot(aes(x = as.integer(as.ordered(year)), y = n, colour = as.factor(recid))) +
  geom_line() +
  scale_x_continuous("year", labels = levels(as.ordered(patients_by_recid$year)))+ 
  labs(x = "Year", y = "Number of Patients") + 
  scale_colour_discrete(name = "Recid")



###############
#COST
###############

###
  # Get total cost by year and spec
recid_by_spec<- data %>%
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year, spec, recid) %>%
  summarise(total_cost = sum(cost_total_net),
            total_beddays = sum(yearstay),
            avg_cost_per_day = total_cost / total_beddays) %>% 
  ungroup()

  #cases to vars for each average cost per day per year
year_diff <- recid_by_spec %>%
  pivot_wider(names_from = "year",
              values_from = c("total_cost", "total_beddays", "avg_cost_per_day")) %>%
  mutate(difference = (avg_cost_per_day_1516 - avg_cost_per_day_1617)/avg_cost_per_day_1516 * 100) %>% 
  ungroup()

  #Create a plot
recid_by_spec %>%
  ggplot(aes(x = year, y = avg_cost_per_day, fill = spec)) +
  geom_col(position = "dodge") +
  facet_wrap("recid")


###
  # Get beddays/avg cost per day/ year/hscp
hscpbeddays<- data %>%
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year, hscp2019) %>%
  summarise(total_cost = sum(cost_total_net),
            total_beddays = sum(yearstay),
            avg_cost_per_day = total_cost / total_beddays) %>% 
  ungroup()


###
  # Get the average cost per day broken down by gender 
avg_cost_by_gender<- data %>%
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year, gender) %>% 
  summarise(total_cost = sum(cost_total_net),
            total_beddays = sum(yearstay),
            avg_cost_per_day = total_cost / total_beddays) %>% 
  ungroup()

avg_cost_by_gender <- avg_cost_by_gender %>% 
  mutate(gender = case_when(gender == 1 ~ "male", 
                            gender == 2 ~ "female", 
                            gender == 9 ~ "not_specified", 
                            gender == 0 ~ "not_known")) %>% 
  # Create a plot 
avg_cost_by_gender %>% 
  ggplot(aes(x = as.integer(as.ordered(year)), y = avg_cost_per_day, colour = as.factor(gender))) +
  geom_line()+
  scale_x_continuous("year", labels = levels(as.ordered(avg_cost_by_gender$year)))


###
  # Avg cost per day across years and Recid 
recid_avg_cost <- data %>%
  filter(recid %in% c("01B", "GLS", "02B", "04B", "AE2")) %>%
  group_by(year, recid) %>%
  summarise(total_cost = sum(cost_total_net),
            total_beddays = sum(yearstay),
            avg_cost_per_day = total_cost / total_beddays) %>% 
  ungroup()

recid_avg_cost %>% 
  ggplot(aes(x = as.integer(as.ordered(year)), y = total_cost, colour = as.factor(recid))) +
  geom_line()+
  scale_x_continuous("year", labels = levels(as.ordered(recid_eps$year)))


###
  # Avg cost per day across years and Recid split by gender and age groups
age_avg_cost <- data %>%
  filter(recid %in% c("01B", "GLS", "02B", "04B", "AE2")) %>%
  group_by(year, recid, gender, Age_group) %>%
  summarise(total_cost = sum(cost_total_net),
            total_beddays = sum(yearstay),
            avg_cost_per_day = total_cost / total_beddays)

age_avg_cost %>%
  ggplot(aes(x = year, y = avg_cost_per_day, fill = Age_group)) +
  geom_col(position = "dodge") +
  facet_wrap("gender")


###
# Get total cost by year and sigfac
sigfac_cost<- data %>%
  filter(recid %in% c("01B", "GLS")) %>%
  group_by(year, sigfac, recid) %>%
  summarise(total_cost = sum(cost_total_net),
            total_beddays = sum(yearstay),
            avg_cost_per_day = total_cost / total_beddays) %>% 
  ungroup()

#Create a plot
sigfac_cost %>%
  ggplot(aes(x = year, y = avg_cost_per_day, fill = sigfac)) +
  geom_col(position = "dodge") +
  facet_wrap("recid")

sigfac_cost %>%
  ggplot(aes(x = as.integer(as.ordered(year)), y = avg_cost_per_day, colour = as.factor(sigfac))) +
           geom_line()+
           scale_x_continuous("year", labels = levels(as.ordered(sigfac_cost$year)))

