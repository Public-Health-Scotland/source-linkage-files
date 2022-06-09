library(furrr)

source("Make_R_files/make_fst_version_functions.R")

years <- purrr::set_names(c("1718", "1819", "1920", "2021", "2122"))

plan(multisession, workers = length(years))
future_map(years, ~ create_fst_files(.x))

create_fst_lookups()
