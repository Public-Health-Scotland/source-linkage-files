#' Process GP ooh cost lookup
#'
#' @description This will read and process the
#' GP ooh cost lookup, it will return the final data
#' but also write this out as a rds.
#'
#' @param data The extract to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @family process extracts
process_costs_gp_ooh <- function(data, write_to_disk = TRUE) {

  # Data Cleaning ---------------------------------------

  ## data - wide to long ##
  gp_ooh_costs <- data %>%
    tidyr::pivot_longer(c(tidyselect::ends_with("_Consultations"), tidyselect::ends_with("_Cost")),
      names_to = c("year", ".value"),
      names_pattern = "(\\d{4})_(.+)"
    ) %>%
    ## create cost per consultation ##
    dplyr::mutate(
      cost_per_consultation = .data$Cost * 1000 / .data$Consultations
    ) %>%
    dplyr::select(
      .data$year,
      .data$HB2019,
      .data$Board_Name,
      .data$cost_per_consultation
    )

  ## add in years by copying the most recent year ##
  latest_cost_year <- max(gp_ooh_costs$.data$year)

  ## increase by 1% for every year after the latest ##
  gp_ooh_costs_uplifted <-
    dplyr::bind_rows(
      gp_ooh_costs,
      purrr:map(1:5, ~
        gp_ooh_costs %>%
          dplyr::filter(year == .data$latest_cost_year) %>%
          dplyr::group_by(.data$year, .data$HB2019, .data$Board_Name) %>%
          dplyr::summarise(
            cost_per_consultation = .data$cost_per_consultation * (1.01)^.x,
            .groups = "drop"
          ) %>%
          dplyr::mutate(year = (as.numeric(convert_fyyear_to_year(.data$year)) + .x) %>%
            convert_year_to_fyyear()))
    ) %>%
    dplyr::arrange(.data$year, .data$HB2019, .data$Board_Name)

  ## match files - to make sure costs haven't changed radically ##
  old_costs <- readr::read_rds(get_gp_ooh_costs_path(update = latest_update())) %>%
    # rename lookup variables to match
    dplyr::rename(
      cost_old = "cost_per_consultation",
      HB2019 = "TreatmentNHSBoardCode",
      year = "Year"
    )

  # match files
  matched_costs_data <- gp_ooh_costs_uplifted %>%
    dplyr::full_join(old_costs, by = c("HB2019", "year")) %>%
    # compute difference
    dplyr::mutate(
      difference = .data$cost_per_consultation - .data$cost_old,
      pct_diff = .data$difference / .data$cost_old * 100
    )

  if (write_to_disk) {
    gp_ooh_costs_uplifted %>%
      dplyr::rename(TreatmentNHSBoardCode = "HB2019") %>%
      # Save .rds file
      write_rds(get_gp_ooh_costs_path(check_mode = "write"))
  }


  # Create charts ---------------------------------------



  return(gp_ooh_costs_uplifted)
}
