# run_sdl.R

# Setup ----
logger::log_info("Run SDL starts.")

library(createslf)

library(DBI)
library(arrow)
library(data.table)
library(dbplyr)
library(dplyr)
library(fs)
library(hms)
library(janitor)
library(keyring)
library(lubridate)
library(magrittr)
library(odbc)
library(openxlsx)
library(phsmethods)
library(phsopendata)
library(purrr)
library(readr)
library(rlang)
library(rmarkdown)
library(readxl)
library(rstudioapi)
library(slfhelper)
library(stringdist)
library(stringr)
library(tibble)
library(tidyr)
library(tidyselect)
library(zoo)
library(knitr)
library(roxygen2)
library(scales)
library(spelling)
library(tarchetypes)
library(targets)
library(testthat)
library(crew)


## Detect BYOC_MODE ----
BYOC_MODE <- Sys.getenv("BYOC_MODE")
# Set up logger and system environment variable BYOC_MODE
if (tolower(BYOC_MODE) %in% c("true", "t")) {
  logger::log_info("Detect run_sdl.r run on Denodo")
  BYOC_MODE <- TRUE
} else {
  logger::log_info("Detect run_sdl.r run locally")
  BYOC_MODE <- FALSE
}

## Set up targets store path ----
store_path <- dplyr::if_else(
  BYOC_MODE,
  "/sdl_byoc/_targets",
  "/conf/sourcedev/Source_Linkage_File_Updates/_targets"
)

## Include reporting of last run date of ACADME ----
if (isFALSE(BYOC_MODE)) {
  denodo_connect <- createslf::get_denodo_connection(BYOC_MODE = BYOC_MODE)
}
dplyr::tbl(
  denodo_connect,
  dbplyr::in_schema("sdl", "sdl_byoc_acadme_load_detail")
) %>%
  dplyr::collect() %>%
  # Optional: Format the date to look clean first
  dplyr::mutate(load_str = format(load_date, "%Y-%m-%d %H:%M:%S")) %>%
  purrr::pwalk(function(data_mart, load_str, ...) {
    logger::log_info("{data_mart} loaded at {load_str}")
  })
if (isFALSE(BYOC_MODE)) {
  odbc::dbDisconnect(denodo_connect)
}

## Set up processing stage and years ----

run_stage <- "extract"

if (!run_stage %in% c("extract", "episode", "individual")) {
  cli::cli_abort(
    "RUN_STAGE must be 'extract', 'episode', or 'individual'."
  )
}

# years <- createslf::years_to_run()
# For use during development
years <- "1920"

year <- years[[1L]]

# Set up run_id and run_date_time ----
# run_id <- Sys.getenv("run_id")
# run_date_time <- Sys.getenv("run_date_time")
# benchmark_run_id <- Sys.getenv("benchmark_run_id")
run_date_time <- script_run_time

write_temp_to_disk <- FALSE
console_outputs <- TRUE

## Extract processing ----

# Build BYOC Output File Paths ----
byoc_output_files <- get_byoc_output_files(
  year,
  #types = "byoc_input_files"
  types = c(
    "postcode_lookup",
    "gpprac_lookup"
  )
)

# targets ----
if (run_stage == "extract") {
  logger::log_info("Targets started.")

  tryCatch(
    log_tar_make(
      script = "SDL_process/dummy_targets.R",
      store = store_path,
      reporter = "verbose"
    ),
    error = function(e) {
      logger::log_error(
        "Targets failed: {conditionMessage(e)}"
      )
      stop(e)
    }
  )

  logger::log_info("Targets finished.")
}

# Episode file processing ----

if (run_stage == "episode") {
  logger::log_info("Episode file processing started.")

  episode_test_results <- purrr::map(years,function(year) {
      logger::log_info(
        "Episode file processing started for {year}."
      )

      if (isFALSE(BYOC_MODE)) {
        write_console_output(
          console_outputs = console_outputs,
          file_type = "episode",
          year = year
        )
      }

    ## Read processed data and create episode file
    log_ep_message("read_data", year)

    processed_data_list <- list(
      "ae" = read_file(get_source_extract_path(year = year, type = "ae", BYOC_MODE = BYOC_MODE)),
      "acute" = read_file(get_source_extract_path(year = year, type = "acute", BYOC_MODE = BYOC_MODE)),
      "at" = read_file(get_source_extract_path(year = year, type = "at", BYOC_MODE = BYOC_MODE)),
      "ch" = read_file(get_source_extract_path(year = year, type = "ch", BYOC_MODE = BYOC_MODE)),
      "cmh" = read_file(get_source_extract_path(year = year, type = "cmh", BYOC_MODE = BYOC_MODE)),
      "nrs_deaths" = read_file(get_source_extract_path(year = year, type = "nrs_deaths", BYOC_MODE = BYOC_MODE)),
      "district_nursing" = read_file(get_source_extract_path(year = year, type = "dn", BYOC_MODE = BYOC_MODE)),
      "gp_ooh" = read_file(get_source_extract_path(year = year, type = "gp_ooh", BYOC_MODE = BYOC_MODE)),
      "hc" = read_file(get_source_extract_path(year = year, type = "hc", BYOC_MODE = BYOC_MODE)),
      "homelessness" = read_file(get_source_extract_path(year = year, type = "homelessness", BYOC_MODE = BYOC_MODE)),
      "maternity" = read_file(get_source_extract_path(year = year, type = "maternity", BYOC_MODE = BYOC_MODE)),
      "mental_health" = read_file(get_source_extract_path(year = year, type = "mh", BYOC_MODE = BYOC_MODE)),
      "outpatients" = read_file(get_source_extract_path(year = year, type = "outpatients", BYOC_MODE = BYOC_MODE)),
      "pis" = read_file(get_source_extract_path(year = year, type = "pis", BYOC_MODE = BYOC_MODE)),
      "sds" = read_file(get_source_extract_path(year = year, type = "sds", BYOC_MODE = BYOC_MODE))
    )

    log_ep_message("creating", year)

    episode_file <- create_episode_file(processed_data_list,
                        year = year,
                        write_temp_to_disk = write_temp_to_disk)

      episode_tests <- process_tests_episode_file(
        data = episode_file,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )

      logger::log_info(
        "Episode file processing completed for {year}."
      )

      return(episode_tests)
    }
  )

  episode_tests_stacked <-
    write_stacked_episode_test_results(
      test_results = episode_test_results,
      BYOC_MODE = BYOC_MODE
    )

  logger::log_info("Episode file processing finished.")
}

# Individual file processing ----

if (run_stage == "individual") {
  logger::log_info("Individual file processing started.")

  individual_test_results <- purrr::map(
    years,
    function(year) {
      logger::log_info(
        "Individual file processing started for {year}."
      )

      if (isFALSE(BYOC_MODE)) {
        write_console_output(
          console_outputs = console_outputs,
          file_type = "individual",
          year = year
        )
      }

      episode_file <- arrow::read_parquet(get_slf_episode_path(year = year)) #TO - DO: Will need
      # to be edited to change where episode file is read from in denodo.

      log_ind_message("creating", year)

      individual_file <- create_individual_file(
        episode_file,
        year = year,
        write_temp_to_disk = write_temp_to_disk
      )

      individual_tests <- process_tests_individual_file(
        data = individual_file,
        year = year,
        BYOC_MODE = BYOC_MODE,
        benchmark_run_id = benchmark_run_id,
        run_id = run_id,
        run_date_time = run_date_time
      )

      logger::log_info(
        "Individual file processing completed for {year}."
      )

      return(individual_tests)
    }
  )

  individual_tests_stacked <-
    write_stacked_individual_test_results(
      test_results = individual_test_results,
      BYOC_MODE = BYOC_MODE
    )

  logger::log_info("Individual file processing finished.")
}

logger::log_info("Run SDL ended.")
