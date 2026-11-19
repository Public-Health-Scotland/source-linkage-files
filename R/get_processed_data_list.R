#' Get SDL Processed Data list for episode file
#'
#' @description A switchboard function that retrieves processed datasets. If `BYOC_MODE`
#' is TRUE, it collects data from Denodo. Otherwise, it sources data locally.
#'
#' @param year Financial year.
#' @param type Name of dataset (e.g. "acute").
#' @param denodo_connect A Denodo connection object.
#' @param BYOC_MODE Logical. TRUE or FALSE.
#'
#' @return data
#'
#' @export
#' @family file path functions
get_processed_data_list <- function(year, type, BYOC_MODE) {
  logger::log_info("Creating processed data list started.")

  processed_data_list <- list(
    "acute" = get_sdl_processed_data(year, type = "acute", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_acute_processed
    "ae" = get_sdl_processed_data(year, type = "ae", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_ae_processed
    # "cmh" = get_sdl_processed_data(year, type = "cmh", BYOC_MODE = BYOC_MODE, run_id = run_id),
    "district_nursing" = get_sdl_processed_data(year, type = "dn", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_dn_processed
    "gp_ooh" = get_sdl_processed_data(year, type = "gp_ooh", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_gp_ooh_processed
    "homelessness" = get_sdl_processed_data(year, type = "homelessness", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_homelessness_processed
    "maternity" = get_sdl_processed_data(year, type = "maternity", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_maternity_processed
    "mental_health" = get_sdl_processed_data(year, type = "mh", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_mh_processed
    "nrs_deaths" = get_sdl_processed_data(year, type = "nrs_deaths", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_nrs_deaths_processed
    "outpatients" = get_sdl_processed_data(year, type = "outpatients", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_outpatients_processed
    # "pis" = get_sdl_processed_data(year, type = "pis", BYOC_MODE = BYOC_MODE, run_id = run_id),
    "sc_at_fy" = get_sdl_processed_data(year, type = "sc_at_fy", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_sc_at_processed (ALL)
    "sc_ch_fy" = get_sdl_processed_data(year, type = "sc_ch_fy", BYOC_MODE = BYOC_MODE, run_id = run_id),# sdl_sc_ch_processed (ALL)
    "sc_hc_fy" = get_sdl_processed_data(year, type = "sc_hc_fy", BYOC_MODE = BYOC_MODE, run_id = run_id), # sdl_sc_hc_processed (ALL)
    "sc_sds_fy" = get_sdl_processed_data(year, type = "sc_sds_fy", BYOC_MODE = BYOC_MODE, run_id = run_id) # sdl_sc_sds_processed (ALL)
  )

  logger::log_info("Creating processed data list finished.")

  processed_data_list$outpatients$age <- as.double(processed_data_list$outpatients$age)

  data_types <- dplyr::bind_rows(
    lapply(names(processed_data_list), function(dataset) {
      data.frame(
        dataset = dataset,
        variable = names(processed_data_list[[dataset]]),
        data_type = sapply(
          processed_data_list[[dataset]],
          function(x) paste(class(x), collapse = ", ")
        ),
        row.names = NULL
      )
    })
  )

  data_type_mismatches <- data_types %>%
    dplyr::group_by(variable) %>%
    dplyr::filter(dplyr::n_distinct(data_type) > 1) %>%
    dplyr::arrange(variable, dataset) %>%
    dplyr::ungroup()

  integer64_vars <- data_type_mismatches %>%
    dplyr::filter(data_type == "integer64")

  for (i in seq_len(nrow(integer64_vars))) {
    dataset <- integer64_vars$dataset[i]
    variable <- integer64_vars$variable[i]

    processed_data_list[[dataset]][[variable]] <-
      as.double(processed_data_list[[dataset]][[variable]])
  }

  return(processed_data_list)
}
