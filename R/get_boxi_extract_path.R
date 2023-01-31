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
get_boxi_extract_path <-
  function(year,
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

    year_dir <- get_year_dir(year, extracts_dir = TRUE)

    if (!check_year_valid(year, type)) {
      return(NA)
    }

    file_name <- dplyr::case_when(
      type == "AE" ~ "A&E-episode-level-extract",
      type == "AE_CUP" ~ "A&E-UCD-CUP-extract",
      type == "Acute" ~ "Acute-episode-level-extract",
      type == "CMH" ~ "Community-MH-contact-level-extract",
      type == "DN" ~ "District-Nursing-contact-level-extract",
      type == "GP_OoH-c" ~ "GP-OoH-consultations-extract",
      type == "GP_OoH-d" ~ "GP-OoH-diagnosis-extract",
      type == "GP_OoH-o" ~ "GP-OoH-outcomes-extract",
      type == "Homelessness" ~ "Homelessness-extract",
      type == "Maternity" ~ "Maternity-episode-level-extract",
      type == "MH" ~ "Mental-Health-episode-level-extract",
      type == "Deaths" ~ "NRS-death-registrations-extract",
      type == "Outpatients" ~ "Outpatients-episode-level-extract"
    )

    boxi_extract_path_csv_gz <- fs::path(
      year_dir,
      glue::glue("{file_name}-20{year}.csv.gz")
    )
    boxi_extract_path_csv <- fs::path(
      year_dir,
      glue::glue("{file_name}-20{year}.csv")
    )

    # If the csv.gz file doesn't exist look for the unzipped csv.
    if (fs::file_exists(boxi_extract_path_csv_gz)) {
      boxi_extract_path <- boxi_extract_path_csv_gz
    } else if (fs::file_exists(boxi_extract_path_csv)) {
      boxi_extract_path <- boxi_extract_path_csv
    } else {
      rlang::abort(glue::glue("{type} Extract not found"))
    }

    return(boxi_extract_path)
  }
