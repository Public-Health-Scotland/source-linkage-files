# Combine Homelessness Completeness files
#
# Original Author - Zihao Li
# Original Date - July 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment
devtools::load_all()

# Source and read file
homelessness_dir <- "/conf/hscdiip/SLF_Extracts/Homelessness"
homelessness_filename <- "2025.11.05 - PHS - Total assessment decisions by LA by Qtr_pivoted.xlsx"
homelessness_file <- file.path(homelessness_dir, homelessness_filename)

homelessness_output <- readxl::read_xlsx(homelessness_file)

# Write parquet
homelessness_output %>%
  write_file(get_sdl_homelessness_completeness_path(check_mode = "write"))
