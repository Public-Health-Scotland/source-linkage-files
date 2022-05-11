#' Get BOXI extract
#'
#' @param year Year of extract
#' @param type Name of BOXI extract
#'
#' @return BOXI extracts containing data for each dataset
#' @export
#'
get_boxi_extract_path <-
  function(year,
           type = c(
             "Acute",
             "Mental",
             "Maternity",
             "Outpatient",
             "AE",
             "AE_CUP",
             "DN",
             "GP_OoH-c",
             "GP_OoH-d",
             "GP_OoH-o",
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
      type == "Mental" ~ "Mental-Health-episode-level-extract",
      type == "Maternity" ~ "Maternity-episode-level-extract",
      type == "Outpatient" ~ "Outpatients-episode-level-extract",
      type == "AE" ~ "A&E-episode-level-extract",
      type == "AE_CUP" ~ "A&E-UCD-CUP-extract",
      type == "DN" ~ "District-Nursing-contact-level-extract",
      type == "GP_OoH-c" ~ "GP-OoH-consultations-extract",
      type == "GP_OoH-d" ~ "GP-OoH-diagnosis-extract",
      type == "GP_OoH-o" ~ "GP-OoH-outcomes-extract",
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
