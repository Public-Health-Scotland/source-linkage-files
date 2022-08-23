#' IT Long Term Conditions File Path
#'
#' @description Get the full path to the IT Long Term Conditions extract
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the LTC extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_ltc_path <- function(...) {
  it_ltc_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "IT_extracts"),
    file_name_regexp = "SCTASK[0-9]{7}_LTCs.+",
    ...
  )

  return(it_ltc_path)
}

#' IT Deaths File Path
#'
#' @description Get the full path to the IT Deaths extract
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the IT Deaths extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_deaths_path <-
  function(it_reference = it_extract_ref(), ...) {
    it_deaths_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "IT_extracts"),
      file_name_regexp = "SCTASK[0-9]{7}_Deaths.+",
      ...
    )

    return(it_deaths_path)
  }

#' IT Prescribing File Path
#'
#' @description Get the full path to the IT PIS extract
#'
#' @param year the year for the required extract
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the PIS extract as an [fs::path()]
#' @export
#' @family extract file paths
#' @seealso [get_file_path()] for the generic function.
get_it_prescribing_path <-
  function(year, ...) {
    it_extracts_dir <- fs::path(get_slf_dir(), "IT_extracts")

    alt_fy <- paste0("20", substr(year, 1, 2))

    # First list all files in the directory which contain
    # the it_reference
    file_name <- fs::dir_ls(it_extracts_dir,
      type = "file",
      regexp = "SCTASK[0-9]{7}"
    ) %>%
      # Get only the file names (not the full path)
      fs::path_file() %>%
      # Will return the full name if it matches,
      # otherwise it will return NA
      stringr::str_extract(pattern = glue::glue("^.+?{alt_fy}\\.csv(:?\\.gz)?$")) %>%
      # This drops all the non-matched names ideally leaving only one.
      stats::na.omit()

    # Abort if there is no file with that name
    if (length(file_name) == 0) {
      rlang::abort(glue::glue(
        "Unable to find file for {year}."
      ))
    }

    # If there is more than one file that matches the pattern, ask the user to choose
    # which one to read in
    if (length(file_name) > 1) {
      prompt <- "Multiple files found! Which one would you like?"
      i <- 1
      for (val in file_name) {
        prompt <- stringr::str_c(prompt, glue::glue("{i}. {val}"), sep = "\n")
        i <- i + 1
      }

      answer <- as.integer(readline(prompt))

      it_prescribing_path <- get_file_path(
        directory = it_extracts_dir,
        file_name = file_name[answer],
        ...
      )

      return(it_prescribing_path)
    } else {
      it_prescribing_path <- get_file_path(
        directory = it_extracts_dir,
        file_name = file_name,
        ...
      )
    }
  }
