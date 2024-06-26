#' Care Home Episodes File Path
#'
#' @description Get the file path for Care Home all episodes file
#'
#' @param update The update month to use,
#' defaults to [latest_update()]
#'
#' @param ... additional arguments passed to [get_file_path()]
#'
#' @return The path to the care home episodes file as an [fs::path()]
#' @export
#' @family social care episodes file paths
#' @seealso [get_file_path()] for the generic function.
get_sc_ch_episodes_path <- function(update = latest_update(), ...) {
  sc_ch_episodes_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care", "processed_sc_all_care_home"),
    file_name = stringr::str_glue("anon-all_ch_episodes_{update}.parquet"),
    ...
  )

  return(sc_ch_episodes_path)
}

#' Alarms and Telecare Episodes File Path
#'
#' @description Get the file path for Alarms and Telecare all episodes file
#'
#' @inheritParams get_sc_ch_episodes_path
#'
#' @return The path to the alarms and telecare episodes file as an [fs::path()]
#' @export
#' @family social care episodes file paths
#' @seealso [get_file_path()] for the generic function.
get_sc_at_episodes_path <- function(update = latest_update(), ...) {
  sc_at_episodes_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care", "processed_sc_all_alarms_telecare"),
    file_name = stringr::str_glue("anon-all_at_episodes_{update}.parquet"),
    ...
  )

  return(sc_at_episodes_path)
}

#' Home Care Episodes File Path
#'
#' @description Get the file path for Home Care all episodes file
#'
#' @inheritParams get_sc_ch_episodes_path
#'
#' @return The path to the care home episodes file as an [fs::path()]
#' @export
#' @family social care episodes file paths
#' @seealso [get_file_path()] for the generic function.
get_sc_hc_episodes_path <- function(update = latest_update(), ...) {
  sc_hc_episodes_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care", "processed_sc_all_home_care"),
    file_name = stringr::str_glue("anon-all_hc_episodes_{update}.parquet"),
    ...
  )

  return(sc_hc_episodes_path)
}

#' SDS Episodes File Path
#'
#' @description Get the file path for Home Care all episodes file
#'
#' @inheritParams get_sc_ch_episodes_path
#'
#' @return The path to the care home episodes file as an [fs::path()]
#' @export
#' @family SDS episodes file paths
#' @seealso [get_file_path()] for the generic function.
get_sc_sds_episodes_path <- function(update = latest_update(), ...) {
  sc_sds_episodes_path <- get_file_path(
    directory = fs::path(get_slf_dir(), "Social_care", "processed_sc_all_sds"),
    file_name = stringr::str_glue("anon-all_sds_episodes_{update}.parquet"),
    ...
  )

  return(sc_sds_episodes_path)
}
