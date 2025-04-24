devtools::load_all()

dir_folder <- "/conf/sourcedev/Source_Linkage_File_Updates"
target_folder <- "/conf/hscdiip/01-Source-linkage-files"
if (!dir.exists(target_folder)) {
  dir.create(target_folder, mode = "770")
}

folders <- years_to_run()
year_n <- length(folders)
resource_consumption <- data.frame(
  year = rep("0", year_n),
  time_consumption = rep(0, year_n),
  file_size_MB = rep(0, year_n)
)

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
