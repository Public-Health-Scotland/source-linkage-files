# Combine DN Cost files
#
# Original Author - Zihao Li
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment ------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
dn_cost_dir <- "/conf/hscdiip/SLF_Extracts/Costs"
dn_cost_filename <- "dn_costs_pivoted.xlsx"
dn_cost_file <- file.path(dn_cost_dir, dn_cost_filename)
print(stringr::str_glue("Use {dn_cost_file}"))


## Stage 2 - Read and clean columns before binding ---------------


## Stage 3 - Bind files together and save to disk -----------
dn_cost_output <- readxl::read_xlsx(dn_cost_file)

dn_cost_output %>%
  write_file(get_sdl_dn_costs_path(check_mode = "write"))
