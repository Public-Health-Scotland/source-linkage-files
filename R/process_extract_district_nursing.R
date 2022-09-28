#' Process the District Nursing extract
#'
#' @description This will read and process the
#' District Nursing extract, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param year The year to process, in FY format.
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_district_nursing <- function(year, data, write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # Data Cleaning  ---------------------------------------
  dn_clean <- data %>%
    # filter for valid chi only
    dplyr::filter(phsmethods::chi_check(.data$chi) == "Valid CHI") %>%
    # add variables
    dplyr::mutate(
      year = year,
      recid = "DN",
      smrtype = add_smr_type(recid = "DN")
    ) %>%
    # deal with gpprac
    dplyr::mutate(gpprac = convert_eng_gpprac_to_dummy(.data$gpprac))


  # Costs  ---------------------------------------

  # Recode HB codes to HB2019 so they match the cost lookup
  dn_costs <- dn_clean %>%
    dplyr::mutate(hbtreatcode = dplyr::recode(.data$hbtreatcode,
      "S08000018" = "S08000029",
      "S08000027" = "S08000030",
      "S08000021" = "S08000031",
      "S08000023" = "S08000032"
    )) %>%
    # match files with DN Cost Lookup
    dplyr::left_join(readr::read_rds(get_dn_costs_path()),
      by = c("hbtreatcode", "year" = "Year")
    ) %>%
    # costs are rough estimates we round them to the nearest pound
    dplyr::mutate(cost_total_net = janitor::round_half_up(.data$cost_total_net)) %>%
    # Create monthly cost vars
    create_day_episode_costs(.data$record_keydate1, .data$cost_total_net)


  ## Aggregate to episodes  ---------------------------------------

  care_marker <- dn_costs %>%
    dplyr::group_by(.data$chi) %>%
    dplyr::arrange(.data$record_keydate1, .by_group = TRUE) %>%
    # Create ccm (Contiuous Care Marker) which will group contacts which occur less
    # than 7 days apart
    dplyr::mutate(ccm = pmax((.data$record_keydate1 - dplyr::lag(.data$record_keydate1)) > 7, FALSE, na.rm = TRUE) %>%
      cumsum())

  dn_episodes <- care_marker %>%
    dplyr::group_by(.data$year, .data$chi, .data$ccm) %>%
    dplyr::summarise(
      recid = dplyr::first(.data$recid),
      smrtype = dplyr::first(.data$smrtype),
      record_keydate1 = min(.data$record_keydate1),
      record_keydate2 = max(.data$record_keydate1),
      dob = dplyr::last(.data$dob),
      gender = dplyr::last(.data$gender),
      gpprac = dplyr::last(.data$gpprac),
      age = dplyr::last(.data$age),
      postcode = dplyr::last(.data$postcode),
      datazone = dplyr::last(.data$datazone),
      lca = dplyr::last(.data$lca),
      hscp = dplyr::last(.data$hscp),
      hbrescode = dplyr::last(.data$hbrescode),
      hbtreatcode = dplyr::last(.data$hbtreatcode),
      location = dplyr::first(.data$location_contact),
      diag1 = dplyr::first(.data$primary_intervention),
      diag2 = dplyr::first(.data$intervention_1),
      diag3 = dplyr::first(.data$intervention_2),
      diag4 = dplyr::last(.data$primary_intervention),
      diag5 = dplyr::last(.data$intervention_1),
      diag6 = dplyr::last(.data$intervention_2),
      cost_total_net = sum(.data$cost_total_net),
      apr_cost = sum(.data$apr_cost),
      may_cost = sum(.data$may_cost),
      jun_cost = sum(.data$jun_cost),
      jul_cost = sum(.data$jul_cost),
      aug_cost = sum(.data$aug_cost),
      sep_cost = sum(.data$sep_cost),
      oct_cost = sum(.data$oct_cost),
      nov_cost = sum(.data$nov_cost),
      dec_cost = sum(.data$dec_cost),
      jan_cost = sum(.data$jan_cost),
      feb_cost = sum(.data$feb_cost),
      mar_cost = sum(.data$mar_cost)
    ) %>%
    dplyr::ungroup()

  if (write_to_disk) {
    # Save as rds file
    dn_episodes %>%
      write_rds(get_source_extract_path(year, "DN", check_mode = "write"))
  }

  return(dn_episodes)
}
