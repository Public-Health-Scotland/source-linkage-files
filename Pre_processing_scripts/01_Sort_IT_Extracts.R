################################################################################
# Name of file -  00_Sort_IT_Extracts.R
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - July 2024
# Written/run on - R Posit
# Version of R - 4.1.2
#
# Description:
#     This script will take the latest IT extract in csv format in:
#     /conf/hscdiip/SLF_Extracts/IT_extracts/
#     convert CHI to ANON CHI and save as a parquet format in:
#     /conf/hscdiip/SLF_Extracts/IT_extracts/anon-chi-IT
#     The previous version will then be archived in:
#     /conf/hscdiip/SLF_Extracts/IT_extracts/archive
#
################################################################################

## Stage 1 - Setup environment
#-------------------------------------------------------------------------------
# load package
devtools::load_all()

# Set up IT extract path
it_extract_path <- file.path(
  get_slf_dir(),
  "IT_extracts"
)

# Set up IT extract ANON CHI path
it_extract_anon_path <- file.path(
  it_extract_path,
  "anon-chi-IT"
)

## Stage 2 - Setup functions
#-------------------------------------------------------------------------------

# Function 1 - detect the previous task number from
# /conf/hscdiip/SLF_Extracts/IT_extracts/anon-chi-IT
get_previous_it_task_num <- function() {
  # List files in directory
  existing_parquet_list <- list.files(it_extract_anon_path)
  # Use the most recent LTC file to detect the task number
  ltcs_file <-
    existing_parquet_list[stringr::str_detect(existing_parquet_list, "LTCs\\.parquet$")]
  # Extract the task number
  task_num <- stringr::str_extract(ltcs_file, "SCTASK\\d+")
  # If the task number = 1 then return the task number
  if (length(task_num) == 1L) {
    return(task_num)
  } else {
    # If there is no task number or more than 1 return NULL
    cli::cli_alert_danger("Detected 0 or more than 1 task numbers! Please check!")
    return(NULL)
  }
}

# Function 2 - detect the latest IT task number extracts from
# /conf/hscdiip/SLF_Extracts/IT_extracts/***.csv
get_new_it_task_num <- function() {
  # List the files in the directory
  new_csv_files <- list.files(it_extract_path)
  # Use the most recent LTC file to detect the task number
  new_ltcs_file <-
    new_csv_files[stringr::str_detect(new_csv_files, "LTCs\\.csv$")]
  # Extract the task number
  new_task_num <- stringr::str_extract(new_ltcs_file, "SCTASK\\d+")
  # If the task number = 1 then return the task number
  if (length(new_task_num) == 1L) {
    return(new_task_num)
    # If there is no task number or more than 1 return NULL
  } else if (length(new_task_num) < 1L) {
    cli::cli_abort("No new IT Extracts detected! Please check!")
    return(NULL)
  } else {
    cli::cli_abort("Detected more than 1 task numbers! Please check!")
    return(NULL)
  }
}

# Store task numbers in the environment
previous_task_num <- get_previous_it_task_num()
new_task_num <- get_new_it_task_num()


# Function 3 - check existing parquet files
# List files in directory
existing_parquet_files <- list.files(it_extract_anon_path, full.names = TRUE)
# Check for previous parquet files
if (is.null(previous_task_num)) {
  cli::cli_alert_info("No IT Extracts from last update to be removed.")
} else {
  # If there are parquet files from the last update, then remove them
  file.remove(existing_parquet_files[grepl(previous_task_num, existing_parquet_files)])
}


## Stage 3 - Convert latest csv IT extracts into parquet format with ANON CHI
#-------------------------------------------------------------------------------

# List latest csv IT extracts
# Note: IT provide this in csv format but the preferred format is parquet
csv_files <- list.files(it_extract_path,
  pattern = "SCTASK[0-9]{7}_(PIS_20[0-9]{2}|Deaths|LTCs)\\.csv(\\.gz)?",
  full.names = TRUE
)

# Function 3 - Convert csv IT extracts into parquet format
convert_it_csv_to_parquet <- function(csv_file) {
  # Replace the ".csv" or ".csv.gz" string with ".parquet"
  parquet_file <- gsub("\\.csv(\\.gz)?$", ".parquet", csv_file)

  # Read the latest csv file
  data <- read_file(csv_file)

  # Supply new file path to
  # /conf/hscdiip/SLF_Extracts/IT_extracts/anon-chi-IT
  # with "anon-" prefix
  new_file <- file.path(
    it_extract_anon_path,
    paste0("anon-", basename(parquet_file))
  )
  # Check if chi is in the csv file
  # If chi is available use slfhelper to get anon_chi
  if (is_chi_in_file(csv_file)) {
    data <- data %>%
      dplyr::rename_with(
        ~ paste0("chi"),
        tidyselect::contains("UPI", ignore.case = FALSE)
      ) %>%
      slfhelper::get_anon_chi()
  }
  # write the file to the new file path on disk
  write_file(data, new_file, group_id = 3206) # hscdiip owner
  cli::cli_alert_info("\n {basename(csv_file)} finished at {Sys.time()}")
}


# Function 4 - check disk available size before moving files
check_hscdiip_available_size <- function() {
  # Get the disk space info for `/conf/hscdiip`
  disk_info <- system("df -h /conf/hscdiip", intern = TRUE)
  # Split the second row into columns (skipping the first header row)
  disk_values <- strsplit(disk_info[2], "\\s+")[[1]]
  # Extract available space (typically the 4th column)
  available_space <- disk_values[4]
  # show the size of csv file
  csv_files_size <- paste0(
    round(file.size(csv_files) %>% sum() / 1024^3, 1),
    "G"
  )
  message <- stringr::str_glue(
    "There are {available_space} avaialable in hscdiip, and the rest of operation requires around {csv_files_size}."
  )
  cli::cli_alert_warning(message)
}

# Use function 4 in the environment
check_hscdiip_available_size()

## Stage 4 - Use lapply to move the list of files from /conf/hscdiip/SLF_Extracts/IT_extracts/
#           to /conf/hscdiip/SLF_Extracts/IT_extracts/anon-chi-IT
#           and also attach anon_chi to the file in place of chi.
#-------------------------------------------------------------------------------
# parallel computing
cli::cli_alert_info("Converting IT Extracts Starts at {Sys.time()}")
lapply(csv_files, convert_it_csv_to_parquet)


## Stage 5 - Tidy up
#-------------------------------------------------------------------------------
# zip and archive current new parquet files
new_parquet_list <- list.files(it_extract_anon_path, full.names = TRUE)
new_parquet_list <- new_parquet_list[grepl(new_task_num, new_parquet_list)]

zip_file_path <- zip::zip(
  zipfile = file.path(
    it_extract_path,
    stringr::str_glue("archive/{new_task_num}_{latest_update()}.zip")
  ),
  files = new_parquet_list,
  compression_level = 9,
  mode = "cherry-pick"
)

# delete csv files in this update
if (file.exists(zip_file_path)) {
  file.remove(csv_files)
}

#-------------------------------------------------------------------------------

# End of Script #
