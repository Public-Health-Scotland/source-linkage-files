# install.packages("fst")

library(haven)
library(janitor)
library(dplyr)
library(fst)
library(stringr)
library(readr)
library(furrr)
library(fs)
plan("multisession")

create_fst_files <- function(year) {
  start_time <- Sys.time()

  slf_sourcedev_dir <- path("/conf/sourcedev/Source Linkage File Updates")

  indiv_path <-
    path(slf_sourcedev_dir, year, str_glue("source-individual-file-20{year}"))
  episode_path <-
    path(slf_sourcedev_dir, year, str_glue("/source-episode-file-20{year}"))


  # Create individual file.
  if (file_exists(path_ext_set(indiv_path, ".zsav"))) {
    write_lines(
      str_glue("Starting individual file for 20{year}.\nIt is now: {start_time}"),
      file = "log",
      append = TRUE
    )

    if (!file_exists(path_ext_set(indiv_path, ".fst"))) {
      read_sav(path_ext_set(indiv_path, ".zsav")) %>%
        rename_all(tolower) %>%
        as_tibble() %>%
        write_fst(path_ext_set(indiv_path, ".fst"), compress = 100)
    } else {
      write_lines(
        str_glue("Skipping 20{year} as fst file already exists in sourcedev"),
        file = "log",
        append = TRUE
      )
    }
  } else {
    write_lines(
      str_glue("Skipping 20{year} as zsav file doesn't exist"),
      file = "log",
      append = TRUE
    )
  }


  # Create episode file.
  if (file_exists(path_ext_set(episode_path, ".zsav"))) {
    write_lines(
      str_glue("Starting episode file for 20{year}.\nIt is now: {Sys.time()}"),
      file = "log",
      append = TRUE
    )

    if (!file_exists(path_ext_set(episode_path, ".fst"))) {
      read_sav(path_ext_set(episode_path, ".zsav")) %>%
        rename_all(tolower) %>%
        as_tibble() %>%
        write_fst(path_ext_set(episode_path, ".fst"), compress = 100)
    } else {
      write_lines(
        str_glue("Skipping 20{year} as fst file already exists in sourcedev"),
        file = "log",
        append = TRUE
      )
    }
  } else {
    write_lines(str_glue("Skipping 20{year}, as zsav file doesn't exist"),
      file = "log",
      append = TRUE
    )
  }

  end_time <- Sys.time()
  time_diff <- difftime(end_time, start_time, units = "mins") %>%
    as.double() %>%
    round_half_up(digits = 1)

  write_lines(str_glue("Done with {year} at {end_time}\nIt took:{time_diff} minutes"),
    file = "log",
    append = TRUE
  )
}

create_fst_lookups <- function() {
  start_time <- Sys.time()

  anon_chi_lookup <-
    path("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup")
  chi_lookup <-
    path("/conf/hscdiip/01-Source-linkage-files/CHI-to-Anon-lookup")

  write_lines(
    str_glue("Starting Anon CHI lookup it is now: {start_time}"),
    file = "log",
    append = TRUE
  )

  read_sav(path_ext_set(anon_chi_lookup, ".zsav")) %>%
    rename_all(tolower) %>%
    as_tibble() %>%
    write_fst(path_ext_set(anon_chi_lookup, ".fst"), compress = 50)

  write_lines(
    str_glue("Starting CHI lookup it is now: {Sys.time()}"),
    file = "log",
    append = TRUE
  )

  read_sav(path_ext_set(chi_lookup, ".zsav")) %>%
    rename_all(tolower) %>%
    as_tibble() %>%
    write_fst(path_ext_set(chi_lookup, ".fst"), compress = 50)

  end_time <- Sys.time()
  time_diff <- difftime(end_time, start_time, units = "mins") %>%
    as.double() %>%
    round_half_up(digits = 1)

  write_lines(
    str_glue("Done with lookups at {end_time}.\nIt took: {time_diff} minutes"),
    file = "log",
    append = TRUE
  )
}

years <- list("1819", "1920", "2021")

future_map(
  years,
  ~ create_fst_files(.x),
  .progress = TRUE
)

create_fst_lookups()
