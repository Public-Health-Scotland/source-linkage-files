


## Read data in ##
data <- readr::read_csv(get_it_deaths_path())


# rename
colnames(data) = c("chi",
                   "death_date_NRS",
                   "death_date_CHI")



## one record per chi ##
data <- data %>%
  dplyr::distinct(chi, .keep_all = TRUE)



## numeric death date ##
data <- data %>%
  tibble::add_column(death_date = as.numeric(NA))




## NRS death date if avaliable ##
for (i in 1:nrow(data)) {
  data$death_date[i] <- ifelse(is.na(data$death_date_NRS[i]) == FALSE,
                     data$death_date_NRS[i],
                     data$death_date_CHI[i])
}



## Save file ##
# //stats/hscdiip/SLF_extracts/Deaths/ #
# get_slf_deaths_path()
saveRDS(data, get_slf_deaths_path())

