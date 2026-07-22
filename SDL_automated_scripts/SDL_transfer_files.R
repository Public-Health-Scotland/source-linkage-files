# SDL_transfer_files
#
# Original Author - Jennifer Thom
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.2.2

## Stage 1 - Setup environment ----
# load package - createslf
devtools::load_all()

# Define Submission date - ### UPDATE ###
submission_date <- "20260722"

# Define version of file - ### UPDATE ###
n <- "1"

# Define list of files - ### UPDATE ###
# file_list <- c(
#   "ch_lookup",
#   "dd",
#   "dn",
#   "dn_contacts",
#   "hhg",
#   "nsu",
#   "spd",
#   "simd",
#   "cmh",
#   "hc_cost_lookup",
#   "dn_cost_lookup",
#   "gpprac_lookup",
#   "ooh_cost_lookup",
#   "readcode",
#   "homelessness_completeness",
#   "hscp_localities",
#   "hscp_population",
#   "datazone_population",
#   "uk_postcode"
# )
file_list <- c("ch_name_lookup", "uk_postcode")

## Stage 2 - run combining those files -----
files <- list.files(
  path = "SDL_automated_scripts",
  pattern = "^Combine_.*\\.R$",
  full.names = TRUE
)

target_files <- files[
  tools::file_path_sans_ext(
    sub("^Combine_", "", basename(files))
  ) %in% file_list
]

lapply(target_files, source)


## Stage 3 - Set up functions ----

# Function for extracting current SDL file paths for transfer
get_sdl_file_paths <- function(file_list) {
  # Match dataset to current file path
  # NOTE: all datasets should be fully combined at this stage.
  # e.g no year specific files
  file_path <- dplyr::recode_values(
    file_list,
    "ch_name_lookup" ~ get_sdl_ch_name_lookup_path(),
    "cmh" ~ get_combined_cmh_path(),
    "dd" ~ get_dd_path(),
    "dn" ~ get_combined_dn_path(),
    "dn_contacts" ~ get_sdl_dn_contacts_path(),
    "dn_cost_lookup" ~ get_sdl_dn_costs_path(),
    "ooh_cost_lookup" ~ get_sdl_gp_ooh_costs_path(),
    "gpprac_lookup" ~ get_sdl_gpprac_lookup_path(),
    "hc_cost_lookup" ~ get_sdl_hc_costs_path(),
    "hhg" ~ get_combined_hhg_path(),
    "nsu" ~ get_combined_nsu_path(),
    "spd" ~ get_spd_path(),
    "simd" ~ get_simd_path(),
    "read_code_lookup" ~ get_readcode_lookup_path(),
    "homelessness_completeness" ~ get_sdl_homelessness_completeness_path(),
    "hscp_localities" ~ get_locality_path(),
    "hscp_population" ~ get_pop_path(type = "hscp"),
    "datazone_population" ~ get_pop_path(type = "datazone"),
    "uk_postcode" ~ get_uk_postcode_path()
  )

  return(file_path)
}

# Function for the SDL output folder
get_sdl_output_path <- function(file_list) {
  # Top level directory
  top_dir <- "/conf/hscdiip/SDL_submission/"

  # Combine with file_list to get name of folder e.g. dd
  output_dir <- stringr::str_glue("{top_dir}{file_list}/")

  # Match file to the new naming convention
  output_name <- dplyr::recode_values(
    file_list,
    # for csv files, no need for `{n}`.
    "ch_name_lookup" ~ stringr::str_glue("SDL_CH_NAME_LOOKUP_{submission_date}_{n}.parquet"),
    "cmh" ~ stringr::str_glue("SDL_CMH_{submission_date}.csv"),
    "dd" ~ stringr::str_glue("SDL_DD_{submission_date}_{n}.parquet"),
    "dn" ~ stringr::str_glue("SDL_DN_{submission_date}.csv"),
    "dn_contacts" ~ stringr::str_glue("SDL_DN_CONTACTS_{submission_date}.csv"),
    "dn_cost_lookup" ~ stringr::str_glue("SDL_DN_COST_LOOKUP_{submission_date}.csv"),
    "ooh_cost_lookup" ~ stringr::str_glue("SDL_OOH_COST_LOOKUP_{submission_date}.csv"),
    "gpprac_lookup" ~ stringr::str_glue("SDL_GPPRAC_LOOKUP_{submission_date}.csv"),
    "hc_cost_lookup" ~ stringr::str_glue("SDL_HC_COST_LOOKUP_{submission_date}.csv"),
    "hhg" ~ stringr::str_glue("SDL_HHG_{submission_date}_{n}.parquet"),
    "nsu" ~ stringr::str_glue("SDL_NSU_{submission_date}_{n}.parquet"),
    "spd" ~ stringr::str_glue("SDL_SPD_{submission_date}_{n}.parquet"),
    "simd" ~ stringr::str_glue("SDL_SIMD_{submission_date}_{n}.parquet"),
    "read_code_lookup" ~ stringr::str_glue("SDL_READ_CODE_LOOKUP_{submission_date}.csv"),
    "homelessness_completeness" ~ stringr::str_glue("SDL_HOMELESSNESS_COMPLETENESS_{submission_date}.csv"),
    "hscp_localities" ~ stringr::str_glue("SDL_HSCP_LOCALITIES_{submission_date}.csv"),
    "hscp_population" ~ stringr::str_glue("SDL_HSCP_POPULATION_{submission_date}.csv"),
    "datazone_population" ~ stringr::str_glue("SDL_DATAZONE_POPULATION_{submission_date}.csv"),
    "uk_postcode" ~ stringr::str_glue("SDL_UK_POSTCODE_{submission_date}_{n}.parquet")
  )

  output_path <- stringr::str_glue("{output_dir}{output_name}")

  return(output_path)
}

# Function for moving files to SDL output location
move_sdl_files <- function(sdl_files, file_list) {
  # Extract old file name
  file_name <- basename(sdl_files)

  sdl_file <- read_file(sdl_files) %>%
    # Create a column containing the old file name
    dplyr::mutate(file_name = file_name) %>%
    # write to disk with new name
    # format SDL_[DATASET]_[YYYYMMDD]_[N].parquet
    write_file(get_sdl_output_path(file_list))
}


## Stage 4 - Use lapply to move the list of files to the correct folders. ----

# return a list of all sdl files for transferring to output folder
# Directory - "/conf/hscdiip/SLF_Extracts/"
sdl_files <- lapply(file_list, get_sdl_file_paths)

# return a list of all sdl output locations
# Directory - "/conf/hscdiip/SDL_submission/"
sdl_output_file_paths <- lapply(file_list, get_sdl_output_path)

# Move files to the new output folders
# Read in each file
# Create a new column with the previous file name
# Save file in new output location with new name
mapply(move_sdl_files, sdl_files, file_list)


## END OF SCRIPT ##
