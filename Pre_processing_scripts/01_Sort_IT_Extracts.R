rm(list = ls())
devtools::load_all()

it_extract_path <- file.path(
  get_slf_dir(),
  "IT_extracts"
)
it_extract_anon_path <- file.path(
  it_extract_path,
  "anon-chi-IT"
)

is_chi_in_file <- function(filename) {
  data <- read.csv(filename, nrow = 1)
  return(grepl("UPI", names(data)) %>% any())
}

# detect task number and tidy up parquet files from last request ---------
# One can manually delete files and comment this part out.
get_previous_it_task_num <- function() {
  existing_parquet_list <- list.files(it_extract_anon_path)
  ltcs_file <-
    existing_parquet_list[stringr::str_detect(existing_parquet_list, "LTCs\\.parquet$")]
  task_num <- stringr::str_extract(ltcs_file, "SCTASK\\d+")
  if (length(task_num) == 1L) {
    return(task_num)
  } else {
    cli::cli_alert_danger("Detected 0 or more than 1 task numbers! Please check!")
    return(NULL)
  }
}

get_new_it_task_num <- function() {
  new_csv_files <- list.files(it_extract_path)
  new_ltcs_file <-
    new_csv_files[stringr::str_detect(new_csv_files, "LTCs\\.csv$")]
  new_task_num <- stringr::str_extract(new_ltcs_file, "SCTASK\\d+")
  if (length(new_task_num) == 1L) {
    return(new_task_num)
  } else if (length(new_task_num) < 1L) {
    cli::cli_abort("No new IT Extracts detected! Please check!")
  } else {
    cli::cli_abort("Detected more than 1 task numbers! Please check!")
  }
}

previous_task_num <- get_previous_it_task_num()
new_task_num <- get_new_it_task_num()

existing_parquet_files <- list.files(it_extract_anon_path, full.names = TRUE)
if (is.null(previous_task_num)) {
  cli::cli_alert_info("No IT Extracts from last update to be removed.")
} else {
  file.remove(existing_parquet_files[grepl(previous_task_num, existing_parquet_files)])
}


# convert csv to anon parquet ---------------------------------------------
csv_files <- list.files(it_extract_path,
  pattern = "SCTASK[0-9]{7}_(PIS_20[0-9]{2}|Deaths|LTCs)\\.csv(\\.gz)?",
  full.names = TRUE
)

convert_it_csv_to_parquet <- function(csv_file) {
  parquet_file <- gsub("\\.csv(\\.gz)?$", ".parquet", csv_file)
  data <- read_file(csv_file)
  new_file <- file.path(
    it_extract_anon_path,
    paste0("anon-", basename(parquet_file))
  )
  if (is_chi_in_file(csv_file)) {
    data <- data %>%
      dplyr::rename_with(
        ~ paste0("chi"),
        tidyselect::contains("UPI", ignore.case = FALSE)
      ) %>%
      slfhelper::get_anon_chi()
  }
  write_file(data, new_file)
  cli::cli_alert_info("\n {basename(csv_file)} finished at {Sys.time()}")
}

# check disk available size before moving files
check_hscdiip_available_size <- function() {
  # Get the disk space info for `/conf/hscdiip`
  disk_info <- system("df -h /conf/hscdiip", intern = TRUE)

  # Split the second row into columns (skipping the first header row)
  disk_values <- strsplit(disk_info[2], "\\s+")[[1]]

  # Extract available space (typically the 4th column)
  available_space <- disk_values[4]

  csv_files_size <- paste0(
    round(file.size(csv_files) %>% sum() / 1024^3, 1),
    "G"
  )
  message <- stringr::str_glue(
    "There are {available_space} avaialable in hscdiip, and the rest of operation requires around {csv_files_size}."
  )
  cli::cli_alert_warning(message)
}

check_hscdiip_available_size()

# parallel computing
cli::cli_alert_info("Converting IT Extracts Starts at {Sys.time()}")
lapply(csv_files, convert_it_csv_to_parquet)


# zip and archive current new parquet files ----------------------------
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

# End of Script #
