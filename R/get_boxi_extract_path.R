#' Get BOXI extract
#'
#' @description Get the BOXI extract path for a given extract and year
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
             "Acute",
             "MH",
             "Maternity",
             "Outpatient",
             "AE",
             "AE_CUP",
             "DN",
             "GPOoH",
             "Deaths",
             "CMH",
             "Homelessness"
           )) {
    type <- match.arg(type)

    year_dir <- fs::path(
      "/conf/sourcedev/Source_Linkage_File_Updates",
      year,
      "Extracts"
    )

    file_name <- dplyr::case_when(
      type == "Acute" ~ "Acute-episode-level-extract",
      type == "MH" ~ "Mental-Health-episode-level-extract",
      type == "Maternity" ~ "Maternity-episode-level-extract",
      type == "Outpatient" ~ "Outpatients-episode-level-extract",
      type == "AE" ~ "A&E-episode-level-extract",
      type == "AE_CUP" ~ "A&E-UCD-CUP-extract",
      type == "DN" ~ "District-Nursing-contact-level-extract",
      type == "GPOoH" ~ "GP-OoH-diagnosis-extract",
      type == "Deaths" ~ "NRS-death-registrations-extract",
      type == "CMH" ~ "Community-MH-contact-level-extract",
      type == "Homelessness" ~ "Homelessness-extract"
    )

    boxi_extract_path_csv_gz <- fs::path(year_dir, glue::glue("{file_name}-20{year}.csv.gz"))
    boxi_extract_path_csv <- fs::path(year_dir, glue::glue("{file_name}-20{year}.csv"))

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
