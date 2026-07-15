# Combine GP OoH Cost files
#
# Original Author - Oluwatobi Oni
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.5.1


# Stage 1 - Setup environment
devtools::load_all()

# Path function for Homelessness Completeness
get_sdl_homelessness_completeness_path <- function(...) {
  get_file_path(
    directory = fs::path(get_slf_dir(), "Homelessness"),
    file_name = "SDL_homelessness_completeness.parquet",
    ...
  )
}

# Source and read file
homelessness_dir <- "/conf/hscdiip/SLF_Extracts/Homelessness"
homelessness_filename <- "2025.11.05 - PHS - Total assessment decisions by LA by Qtr_pivoted.xlsx"
homelessness_file <- file.path(homelessness_dir, homelessness_filename)

homelessness_output <- readxl::read_xlsx(homelessness_file)

# Write parquet
homelessness_output %>%
  write_file(get_sdl_homelessness_completeness_path(check_mode = "write"))
