################################################################################
# Name of file -  copy_to_hscdiip.R
#
# Original Authors - Jennifer Thom, Zihao Li
# Original Date - July 2024
# Written/run on - R Posit
# Version of R - 4.1.2
#
# Description:
#     This script will take the latest version of the SLF episode and individual
#     files in sourcedev and move these to the live folder in:
#     /conf/hscdiip/01-Source-linkage-files
#
#     IMPORTANT:
#         Please refer to the latest version of the SOP. This script is a backup
#         of moving the files to hscdiip. We currently use PUTTY to move the files
#         as this is much faster and more efficient.
#
#         We have retained this script for our records.
#
#
################################################################################

## Stage 1 - Setup environment
#-------------------------------------------------------------------------------

# Load package
devtools::load_all()

# Set up directories
# SOURCEDEV
dir_folder <- "/conf/sourcedev/Source_Linkage_File_Updates"

# HSCDIIP
target_folder <- "/conf/hscdiip/01-Source-linkage-files"
if (!dir.exists(target_folder)) {
  dir.create(target_folder, mode = "770")
}

# Set up years to run for files to be copied over
folders <- years_to_run()
year_n <- length(folders)

# Check how much resource is needed
resource_consumption <- data.frame(
  year = rep("0", year_n),
  time_consumption = rep(0, year_n),
  file_size_MB = rep(0, year_n)
)


## Stage 2 - Create a loop for moving the files from sourcedev to hscdiip
#-------------------------------------------------------------------------------
for (i in 1:year_n) {
  timer <- Sys.time()
  print(stringr::str_glue("{folders[i]} starts at {Sys.time()}"))
  folder_path <- file.path(dir_folder, folders[i])

  file_names <- paste0("source-", c("episode", "individual"), "-file-", folders[i], ".parquet")
  file_names_im <- paste0("source-", c("episode", "individual"), "-file-", folders[i], "-new.parquet")

  old_path <- file.path(folder_path, file_names)
  new_path_im <- file.path(target_folder, file_names_im)
  new_path <- file.path(target_folder, file_names)

  print(file_names)

  fs::file_copy(old_path,
    new_path_im,
    overwrite = TRUE
  )
  fs::file_move(new_path_im, new_path)
  fs::file_chmod(new_path, mode = "770")

  resource_consumption$time_consumption[i] <- (Sys.time() - timer)
  file_size <- sum(file.size(old_path)) / 2^20
  resource_consumption$file_size_MB[i] <- file_size
  print(stringr::str_glue("file size is {file_size}."))
  print(resource_consumption$time_consumption[i])
}

#-------------------------------------------------------------------------------

# End of Script #
