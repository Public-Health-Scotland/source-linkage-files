#' Process costs - Home Care
#'
#' @param denodo_connect connection to denodo
#' @param BYOC_MODE BYOC_MODE
#' @param run_id Denodo identifier
#' @param run_date_time Denodo identifier
#'
#' @export
#'
process_costs_home_care <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                                    BYOC_MODE = FALSE,
                                    run_id = NA,
                                    run_date_time = NA) {

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  ## Read costs
  hc_costs_raw <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "home_care_costs") # TODO: update SDL table
  )

  hc_costs_raw <- readxl::read_excel("/conf/hscdiip/SLF_Extracts/Costs/HC_costs_pivoted.xlsx")

  ## add in years by copying the most recent year ##
  latest_cost_year <- max(hc_costs_raw$year)

  hc_costs <- hc_costs_raw %>%
    dplyr::left_join(
      # TODO: read from Denodo
      phsopendata::get_resource(
        "967937c4-8d67-4f39-974f-fd58c4acfda5",
        col_select = c("CA", "CAName", "HBName")
      ) %>%
        dplyr::distinct(),
      by = c("gss_code" = "CA")
    ) %>%
    dplyr::select(year,
                  ca_name = CAName,
                  health_board = HBName,
                  hourly_cost) %>%
    dplyr::mutate(ca_name = factor(ca_name)) %>%
    dplyr::mutate(year = as.integer(year))

  ## increase by 1% for every year after the latest ##
  hc_costs_uplifted <-
    dplyr::bind_rows(
      hc_costs,
      purrr::map(
        1:5,
        ~
          hc_costs %>%
          dplyr::filter(year == latest_cost_year) %>%
          dplyr::group_by(year, ca_name, health_board) %>%
          dplyr::summarise(hourly_cost = hourly_cost * (1.01)^.x, .groups = "drop") %>%
          dplyr::mutate(year = year + .x)
      )
    ) %>%
    dplyr::arrange(year, ca_name)

  ## Outfile  ---------------------------------------
  outfile <- hc_costs_uplifted %>%
    select(-health_board) %>%
    # Save .rds file
    write_file(
      get_hc_costs_path(check_mode = "write", BYOC_MODE = BYOC_MODE),
      group_id = 3206 # hscdiip owner
    )
}
