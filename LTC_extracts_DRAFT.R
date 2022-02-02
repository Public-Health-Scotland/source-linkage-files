

## financial year in question ##
FY = 1718
year = 2017


# output1718 <- haven::read_sav("/conf/hscdiip/SLF_Extracts/LTCs/LTCs_patient_reference_file-201718.zsav")



## Read data ##
it_extract_ref()
data <- readr::read_csv(get_it_ltc_path())


## Check types / rename ##

# rename
colnames(data) = c("chi",
                   "postcode",
                   "arth_date",
                   "asthma_date",
                   "atrialfib_date",
                   "cancer_date",
                   "cvd_date",
                   "liver_date",
                   "copd_date",
                   "dementia_date",
                   "diabetes_date",
                   "epilepsy_date",
                   "chd_date",
                   "hefailure_date",
                   "ms_date",
                   "parkinsons_date",
                   "refailure_date",
                   "congen_date",
                   "bloodbfo_date",
                   "endomet_date",
                   "digestive_date")



## Create LTC flags 1/0 ##

# Create new variables
data <- data %>%
  tibble::add_column(arth = NA,
                     asthma = NA,
                     atrialfib = NA,
                     cancer = NA,
                     cvd = NA,
                     liver = NA,
                     copd = NA,
                     dementia = NA,
                     diabetes = NA,
                     epilepsy = NA,
                     chd = NA,
                     hefailure = NA,
                     ms = NA,
                     parkinsons = NA,
                     refailure = NA,
                     congen = NA,
                     bloodbfo = NA,
                     endomet = NA,
                     digestive = NA)



# Set flags to 1 or 0 based on FY
# also clear the date if outside of FY

# create ltc and ltc_data
ltc = data[1:10, 22:40]
ltc_date = data[1:10, 3:21]

# fy date to compare to
new_fyyear <- as.numeric(substr(year, 3, 4)) + 1
fyyear_date <- paste0("01-04-", new_fyyear)


for (i in 1:nrow(ltc)) {
  for (j in 1:ncol(ltc)) {

    ifelse(is.na(ltc_date[i,j] == TRUE | ltc_date[i,j] > fyyear_date | ltc_date[i,j] == fyyear_date),
           ltc[i,j] <- 0, ltc[i,j] <- 1)
  }
}


# combine ltc and ltc_date
LTC <- cbind(data[1:10, 1:2], ltc, ltc_date)



## sort data by chi ##
LTC <- LTC %>%
  dplyr::arrange(chi)




## Save out to Year folder - /conf/hscdiip/SLF_Extracts/LTCs ##
# fs::path(get_slf_dir(), "LTCs", "<filename>")

# haven
haven::write_sav(LTC, paste0("LTC_patient_reference_file-20", FY), path = "/conf/hscdiip/SLF_Extracts/LTCs")

# csv
write.csv(LTC, paste0("LTC_patient_reference_file-20", FY, ".csv"), path = "/conf/hscdiip/SLF_Extracts/LTCs")



###########################################################################################################
# as a function # (if can get convert_fyyear_to_year to work)
get_ltc_extracts <- function(data, fyyear) {

  # fyyear to year
  year = convert_fyyear_to_year(fyyear)

  # fy date to compare to
  new_fyyear <- as.numeric(substr(year, 3, 4)) + 1
  fyyear_date <- paste0("01-04-", new_fyyear)


  # create ltc and ltc_data
  ltc = data[1:10, 22:40]
  ltc_date = data[1:10, 3:21]


  # set flags
  for (i in 1:nrow(ltc)) {
    for (j in 1:ncol(ltc)) {

      ifelse(is.na(ltc_date[i,j] == TRUE | ltc_date[i,j] > fyyear_date | ltc_date[i,j] == fyyear_date),
             ltc[i,j] <- 0, ltc[i,j] <- 1)
    }
  }


  # combine chi, postcode, ltc and ltc_date
  LTC <- cbind(data[, 1:2], ltc, ltc_date)

  return (LTC)
}


get_ltc_extracts(data, fyyear = 1819)


###########################################################################################################
