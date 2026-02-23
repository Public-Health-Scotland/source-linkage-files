#' Get BOXI extract
#'
#' @description Get the BOXI extract path for a given extract and year,
#' returns an error message if the extract does not exist if local
#'
#' @param year Year of extract
#' @param type Name of BOXI extract
#'
#' @return BOXI extracts containing data for each dataset
#' @export
#'
#' @family extract file paths
get_boxi_extract_path <- function(year,
                                  type = c(
                                    "ae",
                                    "ae_cup",
                                    "acute",
                                    "acute_cup",
                                    "cmh",
                                    "deaths",
                                    "dn",
                                    "gp_ooh-c",
                                    "gp_ooh-d",
                                    "gp_ooh-o",
                                    "gp_ooh_cup",
                                    "homelessness",
                                    "maternity",
                                    "mh",
                                    "outpatients"
                                  ),
                                  BYOC_MODE = FALSE) {
  type <- match.arg(type)

  # Since BOXI extracts will be only in sourcedev and not needed in Denodo,
  # BYOC_MODE here will be always FALSE.

  # Hence, this function or the if-else part of BYOC_MODE being FALSE will
  # be completely removed after refactoring is completed.
  if (type %in% c("dn", "cmh")) {
    dir <- fs::path(get_slf_dir(), "Archived_data")
  } else {
    dir <- get_year_dir(year, extracts_dir = TRUE, BYOC_MODE)
  }

  if (!check_year_valid(year, type)) {
    return(get_dummy_boxi_extract_path(BYOC_MODE))
  }

  file_name <- dplyr::case_match(
    type,
    "ae" ~ "anon-A&E-episode-level-extract",
    "ae_cup" ~ "anon-A&E-UCD-CUP-extract",
    "acute" ~ "anon-Acute-episode-level-extract",
    "acute_cup" ~ "anon-Acute-CUP-extract",
    "cmh" ~ "anon-Community-MH-contact-level-extract",
    "dn" ~ "anon-District-Nursing-contact-level-extract",
    "gp_ooh-c" ~ "anon-GP-OoH-consultations-extract",
    "gp_ooh-d" ~ "anon-GP-OoH-diagnosis-extract",
    "gp_ooh-o" ~ "anon-GP-OoH-outcomes-extract",
    "gp_ooh_cup" ~ "anon-GP-OoH-CUP-extract",
    "homelessness" ~ "anon-Homelessness-extract",
    "maternity" ~ "anon-Maternity-episode-level-extract",
    "mh" ~ "anon-Mental-Health-episode-level-extract",
    "deaths" ~ "anon-NRS-death-registrations-extract",
    "outpatients" ~ "anon-Outpatients-episode-level-extract"
  )

  if (BYOC_MODE) {
    return(stringr::str_glue("valid_denodo_extract_{file_name}-20{year}"))
  } else{
    boxi_extract_path_csv_gz <- fs::path(dir, stringr::str_glue("{file_name}-20{year}.csv.gz"))

    boxi_extract_path_csv <- fs::path(dir, stringr::str_glue("{file_name}-20{year}.csv"))

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
}

#' Get a path to a dummy file
#'
#' @return an [fs::path()] to a dummy file which can be used with targets.
#' @export
get_dummy_boxi_extract_path <- function(BYOC_MODE = FALSE) {
  if (BYOC_MODE) {
    dummy_path <- "invalid_denodo_extract_path"
  } else {
    dummy_path <- get_file_path(
      directory = get_dev_dir(BYOC_MODE),
      file_name = ".dummy",
      create = TRUE
    )
  }

  return(dummy_path)
}
