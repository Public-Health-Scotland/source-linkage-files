


## Read data ##
data <- readr::read_csv(get_it_ltc_path())

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
