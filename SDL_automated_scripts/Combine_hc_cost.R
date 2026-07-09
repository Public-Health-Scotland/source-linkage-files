# Combine Home Care Cost files
#
# Original Author - Zihao Li
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment ------------------
# load package
devtools::load_all()

# Define the source directory and financial year pattern
hc_cost_dir <- "/conf/hscdiip/SLF_Extracts/Costs"
hc_cost_filename <- "hc_costs_pivoted.xlsx"
hc_cost_file <- file.path(hc_cost_dir, hc_cost_filename)
print(stringr::str_glue("Use {hc_cost_file}"))


## Stage 2 - Read and clean columns before binding ---------------


## Stage 3 - Bind files together and save to disk -----------
hc_cost_output <- readxl::read_xlsx(hc_cost_file)

hc_cost_output %>%
  write_file(get_sdl_hc_costs_path(check_mode = "write"))
