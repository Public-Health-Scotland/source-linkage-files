
## Read data ##
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

# change date types
data <- data %>%
  mutate(arth_date = dmy(arth_date),
         asthma_date = dmy(asthma_date),
         atrialfib_date = dmy(atrialfib_date),
         cancer_date = dmy(cancer_date),
         cvd_date = dmy(cvd_date),
         liver_date = dmy(liver_date),
         copd_date = dmy(copd_date),
         dementia_date = dmy(dementia_date),
         diabetes_date = dmy(diabetes_date),
         epilepsy_date = dmy(epilepsy_date),
         chd_date = dmy(chd_date),
         hefailure_date = dmy(hefailure_date),
         ms_date = dmy(ms_date),
         parkinsons_date = dmy(parkinsons_date),
         refailure_date = dmy(refailure_date),
         congen_date = dmy(congen_date),
         bloodbfo_date = dmy(bloodbfo_date),
         endomet_date = dmy(endomet_date),
         digestive_date = dmy(digestive_date))


## Create LTC flags 1/0 ##

# Create new variables
data <- data %>%
  add_column(arth = 0,
             asthma = 0,
             atrialfib = 0,
             cancer = 0,
             cvd = 0,
             liver = 0 ,
             copd = 0,
             dementia = 0,
             diabetes = 0,
             epilepsy = 0,
             chd = 0,
             hefailure = 0,
             ms = 0,
             parkinsons = 0,
             refailure = 0,
             congen = 0,
             bloodbfo = 0,
             endomet = 0,
             digestive = 0)

# Read data
readr::read_csv(get_it_ltc_path())

# Check types / rename

# Create LTC flags 1/0


# Save out to Year folder - /conf/hscdiip/SLF_Extracts/LTCs
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
