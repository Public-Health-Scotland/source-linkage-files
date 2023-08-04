#' Produce the Homelessness Completeness lookup
#'
#' @param homelessness_data The Homelessness data to produce
#' @inheritParams process_extract_homelessness
#'
#' @return a [tibble][tibble::tibble-package] as a lookup with `year`,
#' `sending_local_authority_name` and the proportion completeness
#' `pct_complete_all`.
produce_homelessness_completeness <- function(
    homelessness_data,
    update,
    sg_pub_path) {
  year <- unique(homelessness_data[["year"]])

  application_counts <- homelessness_data %>%
    dplyr::mutate(assess_fin_year = stringr::str_sub(
      phsmethods::extract_fin_year(.data[["assessment_decision_date"]]),
      end = 4L
    )) %>%
    dplyr::filter(
      .data[["assess_fin_year"]] == convert_fyyear_to_year(year)
    ) %>%
    dplyr::mutate(
      app_ref_clean = stringr::str_remove_all(
        .data[["application_reference_number"]],
        "[^\\w]"
      ) %>%
        toupper() %>%
        stringr::str_squish()
    ) %>%
    dplyr::group_by(
      .data[["year"]],
      .data[["sending_local_authority_name"]]
    ) %>%
    dplyr::summarise(
      applications_boxi = dplyr::n_distinct(.data[["app_ref_clean"]]),
      .groups = "drop"
    )

  sg_all_assessments_annual <-
    openxlsx::read.xlsx(
      sg_pub_path,
      sheet = "Table 1",
      rows = 8L:39L,
      cols = 1L:25L,
      colNames = FALSE
    ) %>%
    dplyr::rename_with(~ c(
      "CAName",
      paste0(paste0("q", 1L:4L), "_", rep(2016L, 4L)),
      paste0(paste0("q", 1L:4L), "_", rep(2017L, 4L)),
      paste0(paste0("q", 1L:4L), "_", rep(2018L, 4L)),
      paste0(paste0("q", 1L:4L), "_", rep(2019L, 4L)),
      paste0(paste0("q", 1L:4L), "_", rep(2020L, 4L)),
      paste0(paste0("q", 1L:4L), "_", rep(2021L, 4L))
    )) %>%
    tidyr::pivot_longer(
      !"CAName",
      names_to = c("fin_quarter", "fin_year"),
      names_pattern = "q(\\d)_(\\d{4})",
      names_transform = list(
        fin_year = as.integer,
        fin_quarter = as.integer
      ),
      values_to = "sg_all_assessments",
      values_ptypes = list(sg_all_assessments = integer())
    ) %>%
    dplyr::mutate(sg_year = convert_year_to_fyyear(.data[["fin_year"]])) %>%
    dplyr::group_by(.data[["CAName"]], .data[["sg_year"]]) %>%
    dplyr::summarise(dplyr::across("sg_all_assessments", sum), .groups = "drop")


  annual_comparison <- dplyr::left_join(
    application_counts,
    sg_all_assessments_annual,
    by = dplyr::join_by(
      "sending_local_authority_name" == "CAName",
      "year" == "sg_year"
    )
  ) %>%
    dplyr::mutate(
      pct_complete_all = .data[["applications_boxi"]] / .data[["sg_all_assessments"]]
    )

  if (anyNA(annual_comparison[["sg_year"]])) {
    cli::cli_warn(
      c(
        "!" = "There are no SG figures for {year}
        so we can't check the completeness.",
        "The Homelessness data will not be filtered."
      )
    )

    return(NULL)
  }

  write_file(
    annual_comparison,
    get_homelessness_completeness_path(
      year = year,
      update = update,
      check_mode = "write"
    )
  )

  return(annual_comparison)
}

#' Homelessness Completeness SG publication figures
#'
#' @description Get the path to the Excel workbook with Homelessness
#' Completeness figures from the SG. These are similar to the figures published
#' by the SG but we have to request it specifically as they don't publish
#' at financial year or quarterly level, which is needed to properly compare.
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the Homelessness Completeness SG publication figures
#' as an [fs::path()].
#'
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_sg_homelessness_pub_path <- function(...) {
  path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Homelessness"),
    file_name = "2022.09.12 - PHS - Total assessment decisions by LA by Qtr.xlsx",
    ...
  )

  last_updated <- lubridate::time_length(
    lubridate::interval(
      fs::file_info(path)[["modification_time"]],
      Sys.Date()
    ),
    unit = "years"
  )

  if (last_updated > 1L) {
    cli::cli_warn(c(
      "!" = "{.file {fs::path_file(path)}} is over a year old.",
      ">" = "Ask the SG team for an updated version.",
      "*" = "{.email Sam.Filippi@gov.scot}",
      "*" = "{.email Sara.White@gov.scot}"
    ))
  }

  return(path)
}


#' Homelessness Completeness lookup path
#'
#' @description Get the path to the Homelessness Completeness lookup. This file
#' is specific to year and update.
#'
#' @param year the financial year of the update.
#' @param update the update month (defaults to use [latest_update()]).
#' @param ... additional arguments passed to [get_file_path()].
#'
#' @return The path to the Homelessness Completeness lookup as an [fs::path()].
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_homelessness_completeness_path <- function(
    year,
    update = latest_update(),
    ...) {
  completeness_file_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Homelessness"),
    file_name = stringr::str_glue(
      "homelessness_completeness_{year}_{update}.parquet"
    ),
    ...
  )

  return(completeness_file_path)
}
