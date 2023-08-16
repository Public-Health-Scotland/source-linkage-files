#' Get BOXI extract
#'
#' @description Get the BOXI extract path for a given extract and year,
#' returns an error message if the extract does not exist
#'
#' @param year Year of extract
#' @param type Name of BOXI extract
#'
#' @return BOXI extracts containing data for each dataset
#' @export
#'
#' @family extract file paths
get_boxi_extract_path <- function(
    year,
    type = c(
      "AE",
      "AE_CUP",
      "Acute",
      "CMH",
      "Deaths",
      "DN",
      "GP_OoH-c",
      "GP_OoH-d",
      "GP_OoH-o",
      "Homelessness",
      "Maternity",
      "MH",
      "Outpatients"
    )) {
  type <- match.arg(type)

  if (type %in% c("DN", "CMH")) {
    dir <- fs::path(get_slf_dir(), "Archived_data")
  } else {
    dir <- get_year_dir(year, extracts_dir = TRUE)
  }

  if (!check_year_valid(year, type)) {
    return(get_dummy_boxi_extract_path())
  }

  file_name <- dplyr::case_match(
    type,
    "AE" ~ "A&E-episode-level-extract",
    "AE_CUP" ~ "A&E-UCD-CUP-extract",
    "Acute" ~ "Acute-episode-level-extract",
    "CMH" ~ "Community-MH-contact-level-extract",
    "DN" ~ "District-Nursing-contact-level-extract",
    "GP_OoH-c" ~ "GP-OoH-consultations-extract",
    "GP_OoH-d" ~ "GP-OoH-diagnosis-extract",
    "GP_OoH-o" ~ "GP-OoH-outcomes-extract",
    "Homelessness" ~ "Homelessness-extract",
    "Maternity" ~ "Maternity-episode-level-extract",
    "MH" ~ "Mental-Health-episode-level-extract",
    "Deaths" ~ "NRS-death-registrations-extract",
    "Outpatients" ~ "Outpatients-episode-level-extract"
  )

  boxi_extract_path_csv_gz <- fs::path(
    dir,
    stringr::str_glue("{file_name}-20{year}.csv.gz")
  )

  boxi_extract_path_csv <- fs::path(
    dir,
    stringr::str_glue("{file_name}-20{year}.csv")
  )

  # If the csv.gz file doesn't exist look for the unzipped csv.
  if (fs::file_exists(boxi_extract_path_csv_gz)) {
    boxi_extract_path <- boxi_extract_path_csv_gz
  } else if (fs::file_exists(boxi_extract_path_csv)) {
    boxi_extract_path <- boxi_extract_path_csv
  } else {
    rlang::abort(stringr::str_glue("{type} Extract not found"))
  }

  return(boxi_extract_path)
}

#' Get a path to a dummy file
#'
#' @return an [fs::path()] to a dummy file which can be used with targets.
get_dummy_boxi_extract_path <- function() {
  get_file_path(
    directory = get_dev_dir(),
    file_name = ".dummy",
    create = TRUE
  )
}
