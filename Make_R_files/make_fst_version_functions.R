write_to_log <- function(message) {
  readr::write_lines(message,
    file = "Make_R_files/log.txt",
    append = TRUE
  )
}

pretty_time_diff <- function(start_time, end_time, units = "mins", digits = 1) {
  time_diff <- difftime(end_time, start_time, units = units) %>%
    as.double() %>%
    janitor::round_half_up(x = ., digits = digits)

  return(time_diff)
}

zsav_to_fst <- function(path, compress) {
  # Read the zsav file
  data <- haven::read_sav(path) %>%
    dplyr::rename_all(tolower)

  # Make a copy
  copy_path <- fs::path(
    fs::path_dir(path),
    stringr::str_replace(
      fs::path_file(path),
      "(.+?)\\.",
      "\\1_pre-fst\\."
    )
  )
  fs::file_copy(path, copy_path)

  # Write the file with haven (as compression is better)
  haven::write_sav(data, path, compress = "zsav")

  # Write the file as an fst version
  data %>%
    fst::write_fst(
      x = .,
      path = fs::path_ext_set(path, "fst"),
      compress = compress
    )

  # Delete the copy (it was just in case any previous steps crashed)
  # Check that the files exist and are bigger than 0 bytes
  if (fs::file_size(path) > 0 & fs::file_size(fs::path_ext_set(path, "fst")) > 0) {
    fs::file_delete(copy_path)
  }
}

create_fst_files <- function(year, compress = 100) {
  start_time <- Sys.time()

  slf_sourcedev_dir <- fs::path("/conf", "sourcedev", "Source_Linkage_File_Updates", year)

  indiv_file_path <-
    fs::path(slf_sourcedev_dir, glue::glue("source-individual-file-20{year}.zsav"))
  ep_file_path <-
    fs::path(slf_sourcedev_dir, glue::glue("source-episode-file-20{year}.zsav"))

  write_to_log(glue::glue("{Sys.time()} - Starting individual file for 20{year}."))

  if (fs::file_exists(indiv_file_path)) {
    if (!fs::file_exists(fs::path_ext_set(indiv_file_path, ".fst"))) {
      # Create individual file
      zsav_to_fst(indiv_file_path, compress = compress)
    } else {
      write_to_log(glue::glue("{Sys.time()} - Skipping 20{year} individual, as the fst file already exists in sourcedev"))
    }
  } else {
    write_to_log(glue::glue("{Sys.time()} - Skipping 20{year} individual, as the zsav file doesn't exist in sourcedev"))
  }

  write_to_log(glue::glue("{Sys.time()} - Starting episode file for 20{year}."))
  if (fs::file_exists(ep_file_path)) {
    if (!fs::file_exists(fs::path_ext_set(ep_file_path, ".fst"))) {
      # Create episode file
      zsav_to_fst(ep_file_path, compress = compress)
    } else {
      write_to_log(glue::glue("{Sys.time()} - Skipping 20{year} episode, as the fst file already exists in sourcedev"))
    }
  } else {
    write_to_log(glue::glue("{Sys.time()} - Skipping 20{year} episode, as the zsav file doesn't exist in sourcedev"))
  }

  time_diff <- pretty_time_diff(start_time, Sys.time())
  finish_message <- glue::glue_col(
    "{green {Sys.time()} - Done with {year}} in {blue {time_diff} minutes}\n"
  )
  write_to_log(finish_message)
  message(finish_message)
}

create_fst_lookups <- function(compress = 100) {
  start_time <- Sys.time()

  hscdiip_slf_dir <- fs::path("/conf", "hscdiip", "01-Source-linkage-files")

  anon_chi_lookup_path <-
    fs::path(hscdiip_slf_dir, "Anon-to-CHI-lookup.zsav")

  chi_lookup_path <-
    fs::path(hscdiip_slf_dir, "CHI-to-Anon-lookup.zsav")

  write_to_log(glue::glue("{Sys.time()} - Starting Anon CHI lookup."))
  zsav_to_fst(anon_chi_lookup_path, compress = compress)

  write_to_log(glue::glue("{Sys.time()} - Starting CHI lookup."))
  zsav_to_fst(chi_lookup_path, compress = compress)

  time_diff <- pretty_time_diff(start_time, Sys.time())
  finish_message <- glue::glue_col(
    "{green {Sys.time()} - Done with lookups} in {blue {time_diff} minutes}\n"
  )
  write_to_log(finish_message)
  message(finish_message)
}
