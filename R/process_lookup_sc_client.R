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
    # group
    dplyr::group_by(.data$sending_location, .data$social_care_id) %>%
    # summarise to take last submission
    dplyr::summarise(dplyr::across(
      c(
        "dementia",
        "mental_health_problems",
        "learning_disability",
        "physical_and_sensory_disability",
        "drugs",
        "alcohol",
        "palliative_care",
        "carer",
        "elderly_frail",
        "neurological_condition",
        "autism",
        "other_vulnerable_groups",
        "living_alone",
        "support_from_unpaid_carer",
        "social_worker",
        "type_of_housing",
        "meals",
        "day_care"
      ),
      ~ as.numeric(dplyr::last(.x))
    )) %>%
    dplyr::ungroup() %>%
    # recode missing with values
    dplyr::mutate(dplyr::across(
      c(
        "support_from_unpaid_carer",
        "social_worker",
        "meals",
        "living_alone",
        "day_care"
        ),
        tidyr::replace_na, 9
      ),
      type_of_housing = tidyr::replace_na(.data$type_of_housing, 6)
    ) %>%
    # factor labels
    dplyr::mutate(
    dplyr::across(
      c(
        "dementia",
        "mental_health_problems",
        "learning_disability",
        "physical_and_sensory_disability",
        "drugs",
        "alcohol",
        "palliative_care",
        "carer",
        "elderly_frail",
        "neurological_condition",
        "autism",
        "other_vulnerable_groups"
      ),
      factor,
      levels = c(0, 1),
      labels = c("No", "Yes")
    ),
    dplyr::across(
      c(
        "living_alone",
        "support_from_unpaid_carer",
        "social_worker",
        "meals",
        "day_care"
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
      .cols = -c("sending_location", "social_care_id"),
      .fn = ~ paste0("sc_", .x)
    )


  ## save outfile ---------------------------------------
  outfile <-
    client_clean %>%
    # reorder
    dplyr::select(
      "sending_location",
      "social_care_id",
      "sc_living_alone",
      "sc_support_from_unpaid_carer",
      "sc_social_worker",
      "sc_type_of_housing",
      "sc_meals",
      "sc_day_care"
    )

  if (write_to_disk) {
    # Save .rds file
    outfile %>%
      write_rds(get_source_extract_path(year, "Client", check_mode = "write"))
  }

  return(outfile)
}
