# Combine GP OoH Cost files
#
# Original Author - Zihao Li
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment ------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
ooh_cost_dir <- "/conf/hscdiip/SLF_Extracts/Costs"
ooh_cost_filename <- "ooh_costs_pivoted.xlsx"
ooh_cost_file <- file.path(ooh_cost_dir, ooh_cost_filename)
print(stringr::str_glue("Use {ooh_cost_file}."))


## Stage 2 - Read and clean columns before binding ---------------


## Stage 3 - Bind files together and save to disk -----------
ooh_cost_output <- readxl::read_xlsx(ooh_cost_file)

ooh_cost_output %>%
  write_file(get_sdl_gp_ooh_costs_path(check_mode = "write"))
