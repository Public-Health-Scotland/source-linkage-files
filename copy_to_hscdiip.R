dir_folder <- "/conf/sourcedev/Source_Linkage_File_Updates"
target_folder <- "/conf/hscdiip/01-Source-linkage-files"
if (!dir.exists(target_folder)) {
  dir.create(target_folder, mode = "770")
}
folders <- c("1718", "1819", "1920", "2021", "2122", "2223")
year_n <- length(folders)
resource_consumption <- data.frame(
  year = rep("0", year_n),
  time_consumption = rep(0, year_n),
  file_size_MB = rep(0, year_n)
)

for (i in 1:length(folders)) {
  timer <- Sys.time()
  print(stringr::str_glue("{folders[i]} starts at {Sys.time()}"))
  folder_path <- file.path(dir_folder, folders[i])
  old_path <- list.files(folder_path,
    pattern = "^source-.*parquet",
    full.names = TRUE
  )
  files_name <- basename(old_path)
  new_path <- file.path(target_folder, files_name)
  print(files_name)

  fs::file_copy(old_path,
    new_path,
    overwrite = TRUE
  )
  resource_consumption$time_consumption[i] <- (Sys.time() - timer)
  file_size <- sum(file.size(old_path)) / 2^20
  resource_consumption$file_size_MB[i] <- file_size
  print(stringr::str_glue("file size is {file_size}."))
  print(resource_consumption$time_consumption[i])
}
