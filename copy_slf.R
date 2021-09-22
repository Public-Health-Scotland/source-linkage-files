library(fs)
library(glue)

copy_slfs <- function(years) {
  # Set folders
  input_folder <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates")
  output_folder <- fs::path("/conf/hscdiip/01-Source-linkage-files")

  # Create a file to alert anyone
  writeLines(
    c(
      "DON'T PANIC!",
      "",
      glue::glue("Update started: {Sys.time()}"),
      glue::glue("The files for {glue::glue_collapse(years, sep = ', ', last = ' and ')} are being updated.")
    ),
    fs::path(output_folder, "Update-In-Progress.txt")
  )

  for (year in years) {
    output_files <- fs::path(
      output_folder,
      c(
        glue::glue("source-episode-file-20{year}.zsav"),
        glue::glue("source-episode-file-20{year}.fst"),
        glue::glue("source-individual-file-20{year}.zsav"),
        glue::glue("source-individual-file-20{year}.fst")
      )
    )

    # Set the files to be writeable
    fs::file_chmod(output_files, mode = 640)

    input_files <- fs::path(
      input_folder, year, fs::path_file(output_files)
    )

    # Copy the files for the given year
    fs::file_copy(input_files, output_folder)

    # Set the files back to read-only
    fs::file_chmod(output_files, mode = 440)
  }

  # Remove the warning message
  fs::file_delete(path(output_folder, "Update-In-Progress.txt"))
}

years_to_copy <- c("1718", "1819")

copy_slfs(years_to_copy)
