#' Process the District Nursing extract
#'
#' @description This will read and process the
#' District Nursing extract, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process
#' @param year The year to process, in FY format.
#' @param costs The cost lookup
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_extract_district_nursing <- function(
    data,
    year,
    costs = read_file(get_dn_costs_path()),
    write_to_disk = TRUE) {
  # Only run for a single year
  stopifnot(length(year) == 1L)

  # Check that the supplied year is in the correct format
  year <- check_year_format(year)

  # If data is available in the FY then run processing.
  if (identical(data, tibble::tibble())) {
    return(data)
  }

  # Data Cleaning  ---------------------------------------
  dn_clean <- data %>%
    # filter for valid chi only
    dplyr::filter(phsmethods::chi_check(.data$chi) == "Valid CHI") %>%
    # add variables
    dplyr::mutate(
      year = year,
      recid = "DN",
      smrtype = add_smrtype(recid = "DN")
    ) %>%
    # deal with gpprac
    dplyr::mutate(gpprac = convert_eng_gpprac_to_dummy(.data$gpprac))


  # Costs  ---------------------------------------

  dn_costs <- dn_clean %>%
    # Recode HB codes to HB2019 so they match the cost lookup
    dplyr::mutate(
      hbtreatcode = dplyr::case_match(
        .data$hbtreatcode,
        "S08000018" ~ "S08000029", # Fife 2014
        "S08000027" ~ "S08000030", # Tayside 2014
        "S08000021" ~ "S08000031", # Glasgow 2018
        "S08000023" ~ "S08000032", # Lanarkshire 2018
        .default = .data$hbtreatcode
      )
    ) %>%
    # match files with DN Cost Lookup
    dplyr::left_join(costs,
      by = c("hbtreatcode", "year")
    ) %>%
    # costs are rough estimates we round them to the nearest pound
    dplyr::mutate(
      cost_total_net = janitor::round_half_up(.data$cost_total_net)
    ) %>%
    # Create monthly cost vars
    create_day_episode_costs(.data$record_keydate1, .data$cost_total_net) %>%
    # Return HB values to HB2018
    dplyr::mutate(
      hbtreatcode = dplyr::case_match(
        .data$hbtreatcode,
        "S08000031" ~ "S08000021", # Glasgow
        "S08000032" ~ "S08000023", # Lanarkshire
        .default = .data$hbtreatcode
      )
    )

  ## Aggregate to episodes  ---------------------------------------

  care_marker <- dn_costs %>%
    dplyr::group_by(.data$chi) %>%
    dplyr::arrange(.data$record_keydate1, .by_group = TRUE) %>%
    # Create CCM (Continuous Care Marker) which will group contacts
    # which occur less than 7 days apart
    dplyr::mutate(
      ccm = pmax(
        (.data$record_keydate1 - dplyr::lag(.data$record_keydate1)) > 7L,
        FALSE,
        na.rm = TRUE
      ) %>%
        cumsum()
    )

  dn_episodes <- care_marker %>%
    dplyr::group_by(.data$year, .data$chi, .data$ccm) %>%
    dplyr::summarise(
      record_keydate1 = min(.data$record_keydate1),
      record_keydate2 = max(.data$record_keydate1),
      dplyr::across(
        c(
          "recid",
          "smrtype",
          "dob",
          "age",
          "gender",
          "gpprac",
          "postcode",
          "datazone2011",
          "lca",
          "hscp",
          "hbrescode",
          "hbtreatcode"
        ),
        ~ dplyr::last(.x)
      ),
      location = dplyr::first(.data$location_contact),
      diag1 = dplyr::first(.data$primary_intervention),
      diag2 = dplyr::first(.data$intervention_1),
      diag3 = dplyr::first(.data$intervention_2),
      diag4 = dplyr::last(.data$primary_intervention),
      diag5 = dplyr::last(.data$intervention_1),
      diag6 = dplyr::last(.data$intervention_2),
      total_no_dn_contacts = dplyr::n(),
      dplyr::across(
        c(
          "cost_total_net",
          dplyr::ends_with("_cost")
        ),
        ~ sum(.x)
      )
    ) %>%
    dplyr::ungroup()

  if (write_to_disk) {
    dn_episodes %>%
      write_file(get_source_extract_path(year, "DN", check_mode = "write"))
  }

  return(dn_episodes)
}
