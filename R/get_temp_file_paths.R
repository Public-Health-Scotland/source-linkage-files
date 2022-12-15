#' Get a temporary version of the SLF
#'
#' @param year The financial year
#' @param temp_version The temp version e.g. 1 or 7
#' @param file_version Episode or Individual file
#'
#' @return The path to the file (`.rds`)
get_slf_temp_path <-
  function(year,
           temp_version,
           file_version = c("episode", "individual")) {
    year <- check_year_format(year)
    file_version <- match.arg(file_version)

    base_dir <- fs::path(
      "/",
      "conf",
      "sourcedev",
      "Source_Linkage_File_Updates"
    )

    year_dir <- fs::path(base_dir, year)

    temp_files_availiable <- fs::dir_ls(year_dir,
      glob = "*temp-*"
    ) %>%
      stringr::str_match(
        glue::glue(
          "temp-source-{file_version}-file-(?<version>[1-9])-{year}\\.rds"
        )
      ) %>%
      .[, "version"]

    temp_files_availiable <-
      temp_files_availiable[!is.na(temp_files_availiable)]

    if (length(temp_files_availiable) == 0L) {
      years_availiable <- fs::dir_ls(
        base_dir,
        recurse = TRUE,
        glob = glue::glue("*temp-source-{file_version}*")
      ) %>%
        stringr::str_match(
          glue::glue(
            "temp-source-{file_version}-file-[1-9]-(?<year>[0-9]{{4}})\\.rds"
          )
        ) %>%
        .[, "year"] %>%
        unique()

      years_formatted <-
        cli::cli_vec(years_availiable[!is.na(years_availiable)],
          style = list("vec-last" = " or ")
        )

      cli::cli_abort(
        c(
          "No temp {file_version} files for {.val {year}}",
          "{cli::qty(years_availiable)}{?There is only/You can choose from} {.val {years_formatted}}."
        ),
        call = rlang::caller_env()
      )
    }

    if (!(temp_version %in% temp_files_availiable)) {
      temp_files_formatted <- cli::cli_vec(temp_files_availiable,
        style = list("vec-last" = " or ")
      )

      cli::cli_abort(
        c(
          "Temp {file_version} file {.val {temp_version}} isn't availiable for {.val {year}}.",
          "{cli::qty(temp_files_availiable)}{?There is only/You can choose from} {.val {temp_files_formatted}}."
        ),
        call = rlang::caller_env()
      )
    }

    # Do check to see which temp versions exist for the given year
    # Return nice error if it doesn't work

    file_name <-
      glue::glue("temp-source-{file_version}-file-{temp_version}-{year}.rds")

    file_path <- get_file_path(
      directory = year_dir,
      file_name = file_name
    )

    return(file_path)
  }

#' Get a temporary version of the SLF episode file
#'
#' @inherit get_slf_temp_path
#'
#' @export
get_slf_ep_temp_path <- function(year, temp_version) {
  get_slf_temp_path(
    year = year,
    temp_version = temp_version,
    file_version = "episode"
  )
}

#' Get a temporary version of the SLF individual file
#'
#' @inherit get_slf_temp_path
#'
#' @export
get_slf_indiv_temp_path <- function(year, temp_version) {
  get_slf_temp_path(
    year = year,
    temp_version = temp_version,
    file_version = "individual"
  )
}
