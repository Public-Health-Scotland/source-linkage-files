write_to_log <- function(message) {
  write_lines(message,
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

zsav_to_fst <- function(file, compress) {
  haven::read_sav(file) %>%
    dplyr::rename_all(tolower) %>%
    tibble::as_tibble() %>%
    fst::write_fst(
      x = .,
      path = fs::path_ext_set(file, ".fst"),
      compress = compress
    )
}

create_fst_files <- function(year, compress = 100) {
  start_time <- Sys.time()

  slf_sourcedev_dir <- fs::path("/conf", "sourcedev", "Source_Linkage_File_Updates", year)

  indiv_file <-
    fs::path(slf_sourcedev_dir, glue::glue("source-individual-file-20{year}.zsav"))
  ep_file <-
    fs::path(slf_sourcedev_dir, glue::glue("source-episode-file-20{year}.zsav"))

  write_to_log(glue::glue("Starting individual file for 20{year}.\nIt is now: {start_time}"))

  if (fs::file_exists(indiv_file)) {
    if (!fs::file_exists(fs::path_ext_set(indiv_file, ".fst"))) {

      # Create individual file
      zsav_to_fst(indiv_file, compress = compress)
    } else {
      write_to_log(glue::glue("Skipping 20{year} individual, as the fst file already exists in sourcedev"))
    }
  } else {
    write_to_log(glue::glue("Skipping 20{year} individual, as the zsav file doesn't exist in sourcedev"))
  }

  write_to_log(glue::glue("Starting episode file for 20{year}.\nIt is now: {Sys.time()}"))
  if (fs::file_exists(ep_file)) {
    if (!fs::file_exists(fs::path_ext_set(ep_file, ".fst"))) {

      # Create episode file
      zsav_to_fst(ep_file, compress = compress)
    } else {
      write_to_log(glue::glue("Skipping 20{year} episode, as the fst file already exists in sourcedev"))
    }
  } else {
    write_to_log(glue::glue("Skipping 20{year} episode, as the zsav file doesn't exist in sourcedev"))
  }

  write_to_log(glue::glue(
    "Done with {year} at {Sys.time()}",
    "\nIt took: {pretty_time_diff(start_time, Sys.time())} minutes"
  ))
}

create_fst_lookups <- function(compress = 100) {
  start_time <- Sys.time()

  hscdiip_slf_dir <- fs::path("/conf", "hscdiip", "01-Source-linkage-files")

  anon_chi_lookup <-
    fs::path(hscdiip_slf_dir, "Anon-to-CHI-lookup.zsav")

  chi_lookup <-
    fs::path(hscdiip_slf_dir, "CHI-to-Anon-lookup.zsav")

  write_to_log(glue::glue("Starting Anon CHI lookup it is now: {start_time}"))
  zsav_to_fst(anon_chi_lookup, compress = compress)

  write_to_log(glue::glue("Starting CHI lookup it is now: {Sys.time()}"))
  zsav_to_fst(chi_lookup, compress = compress)

  write_to_log(glue::glue(
    "Done with lookups at {Sys.time()}.",
    "\nIt took: {pretty_time_diff(start_time, Sys.time())} minutes"
  ))
}
