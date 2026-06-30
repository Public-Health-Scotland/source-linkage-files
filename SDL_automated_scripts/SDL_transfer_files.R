##########################
# SDL_transfer_files
#
# Original Author - Jennifer Thom
# Original Date - June 2026
# Written/run on - R Posit
# Version of R - 4.2.2
##########################

## Stage 1 - Setup environment
#-------------------------------------------------------------------------------
# load package - createslf
devtools::load_all()

# Define Submission date - ### UPDATE ###
submission_date <- "20260630"

# Define version of file - ### UPDATE ###
n <- "1"

# Define list of files - ### UPDATE ###
file_list <- c("dd", "hhg", "nsu", "spd", "simd")

#-------------------------------------------------------------------------------
# Stage 2 - Set up functions
#-------------------------------------------------------------------------------

# Function for extracting current SDL file paths for transfer
get_sdl_file_paths <- function(file_list) {
  # Match dataset to current file path
  # NOTE: all datasets should be fully combined at this stage.
  # e.g no year specific files
  file_path <- dplyr::case_match(
    file_list,
    "dd" ~ get_dd_path(),
    "hhg" ~ get_combined_hhg_path(),
    "nsu" ~ get_combined_nsu_path(),
    "spd" ~ get_spd_path(),
    "simd" ~ get_simd_path()
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
  output_name <- dplyr::case_match(
    file_list,
    "dd" ~ stringr::str_glue("SDL_dd_{submission_date}_{n}.parquet"),
    "hhg" ~ stringr::str_glue("SDL_hhg_{submission_date}_{n}.parquet"),
    "nsu" ~ stringr::str_glue("SDL_nsu_{submission_date}_{n}.parquet"),
    "spd" ~ stringr::str_glue("SDL_spd_{submission_date}_{n}.parquet"),
    "simd" ~ stringr::str_glue("SDL_simd_{submission_date}_{n}.parquet")
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
    dplyr::mutate(
      file_name = file_name
    ) %>%
    # write to disk with new name
    # format SDL_[DATASET]_[YYYYMMDD]_[N].parquet
    write_file(get_sdl_output_path(file_list))
}


#-------------------------------------------------------------------------------
# Stage 3 - Use lapply to move the list of files to the correct folders.
#-------------------------------------------------------------------------------

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
