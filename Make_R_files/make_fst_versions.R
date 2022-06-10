library(furrr)

source("Make_R_files/make_fst_version_functions.R")

years <- list("1415", "1516", "1617", "1718", "1819", "1920", "2021", "2122") %>%
  set_names()

plan(multisession, workers = length(years))
future_map(years, ~ create_fst_files(.x))

create_fst_lookups()
