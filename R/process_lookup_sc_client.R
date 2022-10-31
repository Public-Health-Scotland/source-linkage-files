#' Process the social care client lookup
#'
#' @description This will read and process the
#' social care client lookup, it will return the final data
#' but also write this out as a zsav and rds.
#'
#' @param data The extract to process
#' @param year The year to process
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_sc_client <- function(data, year, write_to_disk = TRUE) {
  # Data Cleaning ---------------------------------------

  client_clean <- data %>%
    dplyr::filter(.data$financial_year == convert_fyyear_to_year(year)) %>%
    # group
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    # summarise to take last submission
    dplyr::summarise(dplyr::across(
      c(
        .data$dementia,
        .data$mental_health_problems,
        .data$learning_disability,
        .data$physical_and_sensory_disability,
        .data$drugs,
        .data$alcohol,
        .data$palliative_care,
        .data$carer,
        .data$elderly_frail,
        .data$neurological_condition,
        .data$autism,
        .data$other_vulnerable_groups,
        .data$living_alone,
        .data$support_from_unpaid_carer,
        .data$social_worker,
        .data$type_of_housing,
        .data$meals,
        .data$day_care
      ),
      ~ as.numeric(dplyr::last(.x))
    )) %>%
    dplyr::ungroup() %>%
    # recode missing with values
    dplyr::mutate(
      dplyr::across(
        c(
          .data$support_from_unpaid_carer,
          .data$social_worker,
          .data$meals,
          .data$living_alone,
          .data$day_care
        ),
        tidyr::replace_na, 9
      ),
      type_of_housing = tidyr::replace_na(.data$type_of_housing, 6)
    ) %>%
    # factor labels
    dplyr::mutate(
      dplyr::across(
        c(
          .data$dementia,
          .data$mental_health_problems,
          .data$learning_disability,
          .data$physical_and_sensory_disability,
          .data$drugs,
          .data$alcohol,
          .data$palliative_care,
          .data$carer,
          .data$elderly_frail,
          .data$neurological_condition,
          .data$autism,
          .data$other_vulnerable_groups
        ),
        factor,
        levels = c(0, 1),
        labels = c("No", "Yes")
      ),
      dplyr::across(
        c(
          .data$living_alone,
          .data$support_from_unpaid_carer,
          .data$social_worker,
          .data$meals,
          .data$day_care
        ),
        factor,
        levels = c(0, 1, 9),
        labels = c("No", "Yes", "Not Known")
      ),
      type_of_housing = factor(.data$type_of_housing,
        levels = c(1:6)
      )
    ) %>%
    # rename variables
    dplyr::rename_with(
      .cols = -c(.data$sending_location, .data$social_care_id),
      .fn = ~ paste0("sc_", .x)
    )


  ## save outfile ---------------------------------------
  outfile <-
    client_clean %>%
    # reorder
    dplyr::select(
      .data$sending_location,
      .data$social_care_id,
      .data$sc_living_alone,
      .data$sc_support_from_unpaid_carer,
      .data$sc_social_worker,
      .data$sc_type_of_housing,
      .data$sc_meals,
      .data$sc_day_care
    )

  if (write_to_disk) {
    # Save .rds file
    outfile %>%
      write_rds(get_source_extract_path(year, "Client", check_mode = "write"))
  }

  return(outfile)
}
