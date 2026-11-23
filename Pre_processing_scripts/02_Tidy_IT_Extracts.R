################################################################################
# Name of file -  00_Sort_IT_Extracts.R (Part 2)
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - July 2024
# Written/run on - R Posit
# Version of R - 4.1.2
#
# Description:
#     This script will tidy up the IT extracts and save the previous version:
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

# List the files in the directory
new_csv_files <- list.files(it_extract_path)
# Use the most recent LTC file to detect the task number
new_ltcs_file <-
  new_csv_files[stringr::str_detect(new_csv_files, "LTCs\\.csv$")]
# Extract the task number
new_task_num <- stringr::str_extract(new_ltcs_file, "SCTASK\\d+")


## Stage 2 - Tidy up
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
