write_to_log <- function(message) {
  write_lines(message,
              file = "Make_R_files/log.txt",
              append = TRUE
  )
}

pretty_time_diff <- function(start_time, end_time) {
  time_diff <- difftime(end_time, start_time, units = "mins") %>%
    as.double() %>%
    round_half_up(digits = 1)

  return(time_diff)
}

zsav_to_fst <- function(file, compress = 100) {
  read_sav(file) %>%
    rename_all(tolower) %>%
    as_tibble() %>%
    write_fst(path_ext_set(file, ".fst"), compress = compress)
}

create_fst_files <- function(year) {
  start_time <- Sys.time()

  slf_sourcedev_dir <- path("/conf", "sourcedev", "Source_Linkage_File_Updates", year)

  indiv_file <-
    path(slf_sourcedev_dir, glue("source-individual-file-20{year}.zsav"))
  ep_file <-
    path(slf_sourcedev_dir, glue("source-episode-file-20{year}.zsav"))


  if (file_exists(indiv_file)) {
    if (!file_exists(path_ext_set(indiv_file, ".fst"))) {
      write_to_log(glue("Starting individual file for 20{year}.\nIt is now: {start_time}"))

      # Create individual file
      zsav_to_fst(indiv_file)

    } else {
      write_to_log(glue("Skipping 20{year} individual, as the fst file already exists in sourcedev"))
    }
  } else {
    write_to_log(glue("Skipping 20{year} individual, as the zsav file doesn't exist in sourcedev"))
  }


  if (file_exists(ep_file)) {
    if (!file_exists(path_ext_set(ep_file, ".fst"))) {
      write_to_log(glue("Starting episode file for 20{year}.\nIt is now: {Sys.time()}"))

      # Create episode file
      zsav_to_fst(ep_file)

    } else {
      write_to_log(glue("Skipping 20{year} episode, as the fst file already exists in sourcedev"))
    }
  } else {
    write_to_log(glue("Skipping 20{year} episode, as the zsav file doesn't exist in sourcedev"))
  }

  end_time <- Sys.time()
  time_diff <- pretty_time_diff(start_time, end_time)

  write_to_log(glue("Done with {year} at {end_time}\nIt took: {time_diff} minutes"))
}

create_fst_lookups <- function() {
  start_time <- Sys.time()

  hscdiip_slf_dir <- path("/conf", "hscdiip", "01-Source-linkage-files")

  anon_chi_lookup <-
    path(hscdiip_slf_dir, "Anon-to-CHI-lookup.zsav")
  chi_lookup <-
    path(hscdiip_slf_dir, "CHI-to-Anon-lookup.zsav")

  write_to_log(glue("Starting Anon CHI lookup it is now: {start_time}"))

  zsav_to_fst(anon_chi_lookup, compress = 50)

  write_to_log(glue("Starting CHI lookup it is now: {Sys.time()}"))

  zsav_to_fst(chi_lookup, compress = 50)

  end_time <- Sys.time()
  time_diff <- pretty_time_diff(start_time, end_time)

  write_to_log(glue("Done with lookups at {end_time}.\nIt took: {time_diff} minutes"))
}
