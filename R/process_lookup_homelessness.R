# It would probably be simplest to create a lookup from the Homelessness data of one row per CHI +
#   start dates of all applications. This can then be matched to episode and individual to easily create the hl1_in_fy flag(s)
# (if someone is in the lookup -> 1, otherwise -> 0). For the episode file, it is slightly more complicated to create the other flags,
# either matching on all the data by CHI and then doing some comparison of dates (as in SPSS),
# or using some of the fancy new joins (dplyr 1.1.0 joins) and doing it that way.
#
#


data <- slfhelper::read_slf_episode("1718", c("anon_chi", "record_keydate1", "record_keydate2", "recid"))

year <-"1718"


create_homelessness_lookup <- function(year) {
  homelessness_lookup <- read_file(get_file_path(get_year_dir(year),
                                                 stringr::str_glue("homelessness_for_source-20{year}"),
                                                 ext = "rds",
                                                 check_mode = "write")) %>%
    dplyr::distinct(chi, record_keydate1, record_keydate2) %>%
    tidyr::drop_na(chi) %>%
    mutate(hl1_in_fy = 1) #%>%
   # group_by(chi) %>%
    #mutate(count = n())

  return(homelessness_lookup)

}


add_homelessness_flag_episode <- function(data, year) {

 lookup <- create_homelessness_lookup(year) %>%
   slfhelper::get_anon_chi()

 ## need to decide which recids this relates to
 data1 <- data %>%
   left_join(lookup %>%
               distinct(anon_chi, hl1_in_fy),
             by = "anon_chi", relationship = "many-to-one") %>%
   mutate(hl1_in_fy = tidyr::replace_na(hl1_in_fy, 0))

  return(data)

}


add_homelessness_date_flags_episode <- function(data, year) {


  lookup <- create_homelessness_lookup(year) %>%
    slfhelper::get_anon_chi() %>%
    rename(application_date = record_keydate1,
         end_date = record_keydate2) %>%
    mutate(six_months_pre_app = application_date - lubridate::days(180),
           six_months_post_app = end_date + lubridate::days(180))

 data1 <- data %>%
   left_join(lookup %>%
                distinct(anon_chi, hl1_in_fy, six_months_pre_app, six_months_post_app, application_date, end_date),
              by = "anon_chi", relationship = "many-to-many") %>%
    filter(hl1_in_fy == 1,
           recid != "HL1") %>%
   # If Range(AssessmentDecisionDate, keydate1_dateformat - time.days(180), keydate1_dateformat - time.days(1)) HH_6before_ep = 1.
    mutate(hl1_6before_ep = ifelse((end_date <= record_keydate2) &
                                     (record_keydate1 <= six_months_post_app), 1 ,0)) %>%


   # If Range(AssessmentDecisionDate, keydate2_dateformat + time.days(180), keydate2_dateformat + time.days(1)) HH_6after_ep = 1.
      mutate(hl1_6after_ep = ifelse((six_months_pre_app <= record_keydate2) &
                                    (record_keydate1 <= application_date), 1 ,0))



 # If Range(AssessmentDecisionDate, keydate1_dateformat, keydate2_dateformat) HH_ep = 1.
  mutate(hl1_during_ep = ifelse((application_date <= record_keydate2) &
                                  (record_keydate1 <= end_date), 1 ,0))


  mutate(hl1_6before_ep = (application_date <= record_keydate1) & (application_date >= six_months_pre_ep) |
           (end_date <= record_keydate2) & (record_keydate1 <= six_months_post_app))





 #
 #
 #
 # hl1_during_ep    filter((application_date <= record_keydate2) & (record_keydate1 <= end_date))
 #
 #
 #
 # Add hl1_6after_ep      filter((end_date <= record_keydate2) &
 #                                 (record_keydate1 <= six_months_post_app))
 #
 #
 # Add hl1_6before_ep   ((six_months_pre_app <= record_keydate2) &
 #                         (record_keydate1 <= application_date))
 #


}



# Numeric HH_ep  HH_6after_ep  HH_6before_ep (F1.0).
# Variable Labels
# HH_in_FY "CHI had an active homelessness application during this financial year"
# HH_ep "CHI had an active homelessness application at time of episode"
# HH_6after_ep "CHI had an active homelessness application at some point 6 months after the end of the episode"
# HH_6before_ep "CHI had an active homelessness application at some point 6 months prior to the start of the episode".
#
# * I'm ignoring PIS (as the dates are not really episode dates), and CH as I'm not sure Care Homes tells us much (and the data is bad).
# Do if any(recid, "00B", "01B", "GLS", "DD", "02B", "04B", "AE2", "OoH", "DN", "CMH", "NRS", "HL1").

#
# * May need to change the numbers here depending on the max number of episodes someone has.
# Do repeat AssessmentDecisionDate = AssessmentDecisionDate.1 to !maxAssessment.
# * If there was an application decision made during episode.
# * HH started during episode.
# If Range(AssessmentDecisionDate, keydate1_dateformat, keydate2_dateformat) HH_ep = 1.
#
# * If there was an application decision made in the 6 months (180 days) after the episode discharged.
# If Range(AssessmentDecisionDate, keydate2_dateformat + time.days(180), keydate2_dateformat + time.days(1)) HH_6after_ep = 1.
#
# * If the was an application decision made in the 6 months prior to admission.
# If Range(AssessmentDecisionDate, keydate1_dateformat - time.days(180), keydate1_dateformat - time.days(1)) HH_6before_ep = 1.
