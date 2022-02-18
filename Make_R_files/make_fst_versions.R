library(haven)
library(janitor)
library(dplyr)
library(fst)
library(glue)
library(readr)
library(furrr)
library(fs)
source("Make_R_files/make_fst_version_functions.R")

years <- list("1718", "1819", "1920", "2021", "2122")

plan(multisession, workers = length(years))

future_map(years, ~ create_fst_files(.x))

create_fst_lookups()
