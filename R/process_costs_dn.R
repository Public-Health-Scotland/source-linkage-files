#' Process costs - District Nursing
#'
#' @description This will read and process the
#' District Nursing costs look up, it will return the final costs look up
#' and (optionally) write it to disk.
#'
#' @param dn_raw_costs Raw district nursing costs data
#' @param dn_contacts District nursing contacts data
#' @param hscp_population HSCP population look up data
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#' @param BYOC_MODE BYOC_MODE
#' @param run_id Denodo identifier
#' @param run_date_time Denodo identifier
#'
#' @return the final look up as a [tibble][tibble::tibble-package].
#' @export
#' @family process cost look ups
process_costs_dn <- function(dn_raw_costs = get_dn_raw_costs_data(BYOC_MODE = BYOC_MODE),
                             dn_contacts = get_dn_contacts_data(BYOC_MODE = BYOC_MODE),
                             hscp_population = get_hscp_pop_data(BYOC_MODE = BYOC_MODE),
                             write_to_disk = TRUE,
                             BYOC_MODE = FALSE,
                             run_id = NA,
                             run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "dn_cost_lookup", year = "all")

  # Define latest year
  latest_year <- check_year_format("1920")

  # Join costs and contacts -------------------------------------

  dn_raw_costs_contacts <- dplyr::left_join(
    dn_contacts %>%
      dplyr::mutate(year = convert_year_to_fyyear(contact_financial_year)),
    dn_raw_costs,
    by = c("hb2019", "year")
  )

  # Process population data -------------------------------------

  # Calculate population cost for NHS Highland with HSCP population ratio.
  # Of the two HSCPs, Argyll and Bute provides the
  # District Nursing data which is 27% of the population.
  population_lookup <- hscp_population %>%
    # Create year as FY = YYYY from CCYY
    dplyr::rename(calendar_year = year) %>%
    dplyr::mutate(year = convert_year_to_fyyear(calendar_year)) %>%
    dplyr::group_by(year, hscp2019name) %>%
    dplyr::summarise(pop = sum(pop)) %>%
    dplyr::mutate(total_pop = sum(pop)) %>%
    dplyr::ungroup() %>%
    # Add Health Board code
    dplyr::mutate(hb2019 = "S08000022") %>%
    # Compute proportion
    dplyr::mutate(
      pop_proportion = pop / total_pop,
      pop_pct = pop_proportion * 100.0
    ) %>%
    # Argyll and Bute is the only HSCP in NHS Highland that submits data
    dplyr::filter(hscp2019name == "Argyll and Bute")

  # Join population data -------------------------------------------

  # Match files
  matched_data <- dplyr::full_join(dn_raw_costs_contacts,
    population_lookup,
    by = c("hb2019", "year")
  ) %>%
    # Recode NA pop_proportion with 1
    dplyr::mutate(pop_proportion = tidyr::replace_na(pop_proportion, 1)) %>%
    # Total net cost
    dplyr::mutate(
      cost_total_net = ((cost * 1000) / (number_of_contacts / pop_proportion))
    ) %>%
    # Sort by HB2019 and year
    dplyr::arrange(hb2019, year) %>%
    # Keep only records with cost
    dplyr::filter(!is.na(cost_total_net))

  # Fix incomplete submissions ------------------------------------------

  # If a Partnership has abnormally low contacts this will
  # affect the cost so use the previous year
  # until we have a complete submission

  # Explore the trends
  matched_data <-
    matched_data %>%
    dplyr::group_by(board_name) %>%
    dplyr::mutate(max_contacts = max(number_of_contacts)) %>%
    dplyr::mutate(pct_of_max = number_of_contacts / max_contacts * 100) %>%
    dplyr::ungroup()

  # Deal with costs ------------------------------------------

  # Costs with pct_of_max < 75 - uplift
  uplift_data <-
    matched_data %>%
    dplyr::mutate(cost_total_net = replace(cost_total_net, pct_of_max < 75, NA)) %>%
    dplyr::group_by(board_name)

  while (anyNA(uplift_data$cost_total_net)) {
    uplift_data <- uplift_data %>%
      dplyr::mutate(cost_total_net = dplyr::if_else(
        is.na(cost_total_net),
        dplyr::lag(cost_total_net) * 1.01,
        cost_total_net
      ))
  }

  uplift_data <- dplyr::ungroup(uplift_data)

  # Add in years by copying the most recent year we have
  new_years_data <-
    dplyr::bind_rows(
      uplift_data,
      purrr::map_df(1:5, ~
        uplift_data %>%
          dplyr::filter(year == latest_year) %>%
          dplyr::mutate(
            cost_total_net = cost_total_net * (1.01)^.x,
            year = convert_year_to_fyyear(as.numeric(convert_fyyear_to_year(year)) + .x)
          ))
    )

  new_years_data <-
    new_years_data %>%
    dplyr::rename(
      hbtreatcode = "hb2019",
      hbtreatname = "treatment_nhs_board_name"
    ) %>%
    dplyr::select(year, hbtreatcode, hbtreatname, cost_total_net) %>%
    dplyr::arrange(hbtreatcode, year)

  # Save outfile ---------------------------------------

  outfile <-
    new_years_data %>%
    dplyr::select(
      year,
      hbtreatcode,
      hbtreatname,
      cost_total_net
    ) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )

  if (write_to_disk) {
    write_file(
      data = outfile,
      path = get_dn_costs_path(
        BYOC_MODE = BYOC_MODE,
        check_mode = "write"
      ),
      group_id = 3206, # hscdiip owner
      BYOC_MODE = BYOC_MODE
    )
  }

  log_slf_event(stage = "process", status = "complete", type = "dn_cost_lookup", year = "all")

  return(outfile)
}
