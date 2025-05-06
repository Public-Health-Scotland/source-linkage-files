#' targets_console_path
#'
#' @return the path of the folder where a target console output is
#'
#' @examples targets_console_path()
targets_console_path <- function() {
  return("Run_SLF_Files_targets/console_outputs")
}

#' ep_ind_console_path
#'
#' @return the path of the folder where a ep or ind file console output is
#'
#' @examples ep_ind_console_path("ep_1415_console_2025-04-30_15-06-54.txt")
ep_ind_console_path <- function() {
  return("Run_SLF_Files_manually/console_outputs")
}

#' Extract time stamp and time consumption of ep or ind files
#'
#' @param file_name ep or ind file console output file name
#'
#' @return write a csv of time consumption to disk
#'
#' @examples
extract_ep_ind_time <- function(file_name) {
  file_path <- get_file_path(
    ep_ind_console_path(),
    file_name
  )
  log_data <- readLines(file_path)
  # Extract relevant details
  log_df <- data.frame(log_data) %>%
    tidyr::extract(
      log_data,
      into = c("function_name", "status", "timestamp"),
      regex = "ℹ (.*?) (started|finished) at (.*)",
      remove = FALSE
    ) %>%
    mutate(timestamp = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>%
    filter(!is.na(function_name))

  # Join and calculate duration
  function_times <- log_df %>%
    mutate(
      duration_sec = difftime(timestamp, lag(timestamp), units = "secs"),
      duration_min = as.numeric(duration_sec, units = "mins")
    )

  readr::write_csv(function_times,
    path = sub(".txt", ".csv", file_path)
  )
}

#' Extract time stamp and time consumption of targets console output
#'
#' @param file_name targets console output file name
#'
#' @return write a csv of time consumption to disk
#'
#' @examples extract_targets_time("targets_console_2025-04-30_11-28-57.txt")
extract_targets_time <- function(file_name) {
  file_path <- get_file_path(
    targets_console_path(),
    file_name
  )
  log_lines <- readLines(file_path)

  # Updated regular expression pattern to capture the target name, value, and measure
  pattern <-
    "completed target (\\S+) \\[([0-9]+(?:\\.[0-9]+)?) (seconds|minutes)\\]"

  # Apply the regex pattern and extract the data
  matches <- regmatches(log_lines, regexec(pattern, log_lines))

  # Create a data frame to store the extracted data
  extracted_data <- data.frame(
    target = sapply(matches, function(x) {
      if (length(x) > 0) {
        x[2]
      } else {
        NA
      }
    }),
    value = as.numeric(sapply(matches, function(x) {
      if (length(x) > 0) {
        x[3]
      } else {
        NA
      }
    })),
    measure = sapply(matches, function(x) {
      if (length(x) > 0) {
        x[4]
      } else {
        NA
      }
    })
  ) %>%
    dplyr::filter(!is.na(target)) %>%
    dplyr::mutate(
      unit_min = dplyr::case_when(
        measure == "seconds" ~ value / 60,
        measure == "minutes" ~ value,
        .default = -1
      ),
      unit_sec = dplyr::case_when(
        measure == "seconds" ~ value,
        measure == "minutes" ~ value * 60,
        .default = -1
      ),
      year_specific = grepl("_\\d{4}$", target)
    ) %>%
    dplyr::select(target, unit_sec, unit_min, year_specific) %>%
    dplyr::arrange(target, unit_min)

  readr::write_csv(extracted_data,
    path = sub(".txt", ".csv", file_path)
  )
}
