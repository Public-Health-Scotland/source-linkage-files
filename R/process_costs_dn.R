#' Process costs - District Nursing
#'
#' @param denodo_connect connection to denodo
#' @param BYOC_MODE BYOC_MODE
#' @param run_id Denodo identifier
#' @param run_date_time Denodo identifier
#'
#' @export
#'

process_costs_dn <- function(denodo_connect = get_denodo_connection(BYOC_MODE = BYOC_MODE),
                             # dn_raw_costs_path = get_dn_raw_costs_path(), # TODO: Check if needed. If it is function will need to be refactored to include the BYOC_MODE argument.
                             # dn_raw_contacts_path = fs::path(get_slf_dir(), "Costs", "DN-Contacts-Numbers-for-Costs.csv"), # TODO: Check if needed. If it is function will need to be refactored to include the BYOC_MODE argument.
                             # pop_path = get_pop_path(type = "hscp"), # TODO: Check if needed. If it is function will need to be refactored to include the BYOC_MODE argument.
                             BYOC_MODE = FALSE,
                             run_id = NA,
                             run_date_time = NA) {
  log_slf_event(stage = "process", status = "start", type = "dn_costs", year = year) # TODO: Check this is necessary.

  on.exit(try(DBI::dbDisconnect(denodo_connect), silent = TRUE), add = TRUE)

  # Read in cost workbook ---------------------------------------

  # latest year #
  latest_year <- check_year_format("1920")

  ## data ##
  dn_raw_costs <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_dn_costs_source")
  ) %>% # TODO: Placeholder. Check table name.
    dplyr::collect() %>%
    janitor::clean_names() %>%
    # change 1718 type to numeric - reads in as a character
    mutate(across(ends_with("_cost"), as.numeric)) %>% # TODO: Remove this if the issue is resolved in Denodo view.
    # pivot longer
    pivot_longer(
      ends_with("_cost"),
      names_to = "year",
      names_pattern = "(\\d{4})_cost",
      values_to = "cost"
    )

  # Read DN file extracted from BOXI -----------------------------

  # contacts
  dn_raw_contacts <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_dn_contacts_source")
  ) %>% # TODO: Placeholder. Check table name and whether dataset exists.
    dplyr::collect() %>%
    janitor::clean_names() %>%
    # create year variable as fy
    mutate(year = convert_year_to_fyyear(contact_financial_year)) %>%
    # rename TreatmentNHSBoardCode
    rename(
      hb2019 = treatment_nhs_board_code_9, # TODO: Check Denodo column names.
      number_of_contacts = number_of_contacts # TODO: Check Denodo column names.
    )

  # Join files together ------------------------------------------

  # match raw costs to contacts file
  dn_raw_costs_contacts <- left_join(dn_raw_contacts,
    dn_raw_costs,
    by = c("hb2019", "year")
  )


  # Deal with population cost-------------------------------------

  ## Calculate population cost for NHS Highland with HSCP population ratio. ##
  # Of the two HSCPs, Argyll and Bute provides the
  # District Nursing data which is 27% of the population.
  population_lookup <- dplyr::tbl(
    denodo_connect,
    dbplyr::in_schema("sdl", "sdl_pop_source")
  ) %>% # TODO: Placeholder.Check table name and whether dataset exists.
    # Select only the HSCPs for NHS Highland & years since 2015
    filter(
      hscp2019 %in% c("S37000004", "S37000016"), # TODO: Check column exists in Denodo view.
      year >= 2015L # TODO: Check column exists in Denodo view.
    ) %>%
    dplyr::collect() %>%
    # Create year as FY = YYYY from CCYY.
    rename(calendar_year = year) %>%
    mutate(year = convert_year_to_fyyear(calendar_year)) %>%
    group_by(year, hscp2019name) %>%
    summarise(pop = sum(pop)) %>%
    mutate(total_pop = sum(pop)) %>%
    ungroup() %>%
    # add Health Board code
    mutate(hb2019 = "S08000022") %>%
    ## compute proportion ##
    mutate(
      pop_proportion = pop / total_pop,
      pop_pct = pop_proportion * 100.0
    ) %>%
    ## Argyll and Bute is the only HSCP in NHS Highland that submits data ##
    filter(hscp2019name == "Argyll and Bute")


  # Join files -------------------------------------------

  ## match files ##

  matched_data <- full_join(dn_raw_costs_contacts,
    population_lookup,
    by = c("hb2019", "year")
  ) %>%
    # recode NA pop_proportion with 1
    mutate(pop_proportion = replace_na(pop_proportion, 1)) %>%
    ## total net cost ##
    mutate(
      cost_total_net = ((cost * 1000) / (number_of_contacts / pop_proportion))
    ) %>%
    # sort by HB2019 and year
    arrange(hb2019, year) %>%
    # keep only records with cost
    filter(!is.na(cost_total_net))


  # Fix incomplete submissions ------------------------------------------

  # If a Partnership has abnormally low contacts this will
  # affect the cost so use the previous year
  # until we have a complete submission

  ## explore the trends

  matched_data <-
    matched_data %>%
    group_by(board_name) %>%
    mutate(max_contacts = max(number_of_contacts)) %>%
    mutate(pct_of_max = number_of_contacts / max_contacts * 100) %>%
    ungroup()

  # Deal with costs ------------------------------------------

  ## costs with pct_of_max < 75 - uplift ##
  uplift_data <-
    matched_data %>%
    mutate(cost_total_net = replace(cost_total_net, pct_of_max < 75, NA)) %>%
    group_by(board_name)


  while (anyNA(uplift_data$cost_total_net)) {
    uplift_data <- uplift_data %>%
      mutate(cost_total_net = if_else(is.na(cost_total_net),
        lag(cost_total_net) * 1.01,
        cost_total_net
      ))
  }

  uplift_data <- ungroup(uplift_data)

  ## Add in years by copying the most recent year we have ##

  new_years_data <-
    bind_rows(
      uplift_data,
      map_df(1:5, ~
        uplift_data %>%
          filter(year == latest_year) %>%
          mutate(
            cost_total_net = cost_total_net * (1.01)^.x,
            year = convert_year_to_fyyear(as.numeric(convert_fyyear_to_year(year)) + .x)
          ))
    )

  new_years_data <-
    new_years_data %>%
    rename(
      hbtreatcode = "hb2019",
      hbtreatname = "treatment_nhs_board_name"
    ) %>%
    select(year, hbtreatcode, hbtreatname, cost_total_net) %>%
    arrange(hbtreatcode, year)

  ## save outfile ---------------------------------------
  outfile <-
    new_years_data %>%
    select(
      year,
      hbtreatcode,
      hbtreatname,
      cost_total_net
    ) %>%
    dplyr::mutate(
      run_id = run_id,
      run_date_time = run_date_time
    )

  outfile %>%
    # Save .rds file
    write_file(get_dn_costs_path(check_mode = "write", BYOC_MODE = BYOC_MODE),
      group_id = 3206, # hscdiip owner
      BYOC_MODE = BYOC_MODE
    )

  log_slf_event(stage = "process", status = "complete", type = "dn_costs", year = "all") # TODO: Check this is necessary.

  return(outfile)
}
