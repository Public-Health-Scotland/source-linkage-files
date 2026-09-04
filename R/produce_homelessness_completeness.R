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
  sg_pub_data = get_sg_pub_data(BYOC_MODE = BYOC_MODE),
  BYOC_MODE,
  run_id = NA,
  run_date_time = NA
) {
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

  annual_comparison <- dplyr::left_join(
    application_counts,
    sg_pub_data,
    by = dplyr::join_by(
      "sending_local_authority_name" == "caname",
      "year" == "sg_year"
    )
  ) %>%
    dplyr::mutate(
      sg_all_assessments = as.integer(sg_all_assessments),
      pct_complete_all = .data[["applications_boxi"]] / .data[["sg_all_assessments"]],
      run_id = run_id,
      run_date_time = run_date_time
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
      check_mode = "write",
      BYOC_MODE = BYOC_MODE
    ),
    BYOC_MODE = BYOC_MODE
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
    file_name = "2025.11.05 - PHS - Total assessment decisions by LA by Qtr.xlsx",
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

#' Homelessness Completeness SG publication figures
#'
#' @description get homelessness completeness SG publication figures
#'
#' @param denodo_connect Connection to denodo
#' @param BYOC_MODE BYOC MODE
#'
#' @return a [tibble][tibble::tibble-package].
#' @export
#'
#' @family lookup files
get_sg_homelessness_pub_data <- function(
  denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
  BYOC_MODE
) {
  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  log_slf_event(
    stage = "read",
    status = "start",
    type = "homelessness_completeness",
    year = "all"
  )

  if (isTRUE(BYOC_MODE)) {
    sg_pub_data <- dplyr::tbl(
      denodo_connect,
      dbplyr::in_schema("sdl", "sdl_homelessness_completeness_source")
    ) %>%
      dplyr::rename("caname" = "local_authority", "sg_year" = "fin_year") %>%
      dplyr::collect() %>%
      dplyr::mutate(sg_year = convert_year_to_fyyear(sg_year)) %>%
      dplyr::summarise(
        sg_all_assessments = sum(sg_all_assessments),
        .by = c("caname", "sg_year")
      ) %>%
      dplyr::arrange(caname, sg_year)
  } else {
    sg_pub_data <- openxlsx::read.xlsx(
      get_sg_homelessness_pub_path(),
      sheet = "Table 1", # Manual change - check sheet name
      rows = 8L:39L,
      cols = 1L:37L, # Manual change - check workbook for col number for latest year
      colNames = FALSE
    ) %>%
      dplyr::rename_with(~ c(
        "caname",
        paste0(paste0("q", 1L:4L), "_", rep(2016L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2017L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2018L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2019L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2020L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2021L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2022L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2023L, 4L)),
        paste0(paste0("q", 1L:4L), "_", rep(2024L, 4L))
        ## Manual change - Add new row here when new year is available in publication
      )) %>%
      tidyr::pivot_longer(
        !"caname",
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
      dplyr::group_by(.data[["caname"]], .data[["sg_year"]]) %>%
      dplyr::summarise(dplyr::across("sg_all_assessments", sum), .groups = "drop")
  }

  log_slf_event(
    stage = "read",
    status = "complete",
    type = "homelessness_completeness",
    year = "all"
  )

  return(sg_pub_data)
}


#' Homelessness Completeness lookup path
#'
#' @description Get the path to the Homelessness Completeness lookup. This file
#' is specific to year and update.
#'
#' @param year the financial year of the update.
#' @param ... additional arguments passed to [get_file_path()].
#' @param BYOC_MODE check BYOC mode.
#'
#' @return The path to the Homelessness Completeness lookup as an [fs::path()].
#' @export
#' @family file path functions
#' @seealso [get_file_path()] for the generic function.
get_homelessness_completeness_path <- function(
  year,
  BYOC_MODE,
  ...
) {
  if (BYOC_MODE) {
    completeness_file_path <- fs::path(
      directory = denodo_output_path(),
      file_name = stringr::str_glue(
        "homelessness_completeness-20{year}.parquet"
      )
    )
  } else {
    completeness_file_path <- get_file_path(
      directory = fs::path(get_slf_dir(), "Homelessness"),
      file_name = stringr::str_glue(
        "homelessness_completeness-20{year}.parquet"
      ),
      ...
    )
  }

  return(completeness_file_path)
}
