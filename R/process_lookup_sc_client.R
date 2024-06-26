#' Process the social care client lookup
#'
#' @description This will read and process the
#' social care client lookup, it will return the final data
#' and (optionally) write it to disk.
#'
#' @param data The extract to process
#' @param year The year to process
#' @param sc_demographics social care demographics file
#' @param write_to_disk (optional) Should the data be written to disk default is
#' `TRUE` i.e. write the data to disk.
#'
#' @return the final data as a [tibble][tibble::tibble-package].
#' @export
#' @family process extracts
process_lookup_sc_client <-
  function(data,
           year,
           sc_demographics = read_file(get_sc_demog_lookup_path()) %>%
             slfhelper::get_chi() %>%
             dplyr::select(c("sending_location", "social_care_id", "chi")),
           write_to_disk = TRUE) {
    client_clean <- data %>%
      # Replace 'unknown' responses with NA
      dplyr::mutate(
        dplyr::across(
          c(
            "support_from_unpaid_carer",
            "social_worker",
            "meals",
            "living_alone",
            "day_care"
          ),
          dplyr::na_if,
          9L
        ),
        type_of_housing = dplyr::na_if(.data$type_of_housing, 6L)
      ) %>%
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
        dplyr::last
      )) %>%
      dplyr::ungroup() %>%
      # Recode NA with 'unknown' values
      dplyr::mutate(
        dplyr::across(
          c(
            "support_from_unpaid_carer",
            "social_worker",
            "meals",
            "living_alone",
            "day_care"
          ),
          tidyr::replace_na,
          9L
        ),
        type_of_housing = tidyr::replace_na(.data$type_of_housing, 6L)
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
          levels = c(0L, 1L),
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
          levels = c(0L, 1L, 9L),
          labels = c("No", "Yes", "Not Known")
        ),
        type_of_housing = factor(.data$type_of_housing,
          levels = 1L:6L
        )
      ) %>%
      # rename variables
      dplyr::rename_with(
        .cols = -c("sending_location", "social_care_id"),
        .fn = ~ paste0("sc_", .x)
      )

    sc_client_lookup <- client_clean %>%
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

    # Match to demographics lookup to get CHI
    sc_client_lookup <- sc_client_lookup %>%
      dplyr::left_join(
        sc_demographics,
        by = c("sending_location", "social_care_id")
      )
    sc_client_lookup <-
      dplyr::mutate(sc_client_lookup,
        count_not_known = rowSums(
          dplyr::select(sc_client_lookup, tidyr::all_of(
            c(
              "sc_living_alone",
              "sc_support_from_unpaid_carer",
              "sc_social_worker",
              "sc_meals",
              "sc_day_care"
            )
          )) == "Not Known",
          na.rm = TRUE
        )
      ) %>%
      dplyr::arrange(.data$chi, .data$count_not_known) %>%
      dplyr::distinct(.data$chi, .keep_all = TRUE) %>%
      dplyr::select(-.data$sending_location) %>%
      slfhelper::get_anon_chi()

    if (write_to_disk) {
      write_file(
        sc_client_lookup,
        get_sc_client_lookup_path(year, check_mode = "write")
      )
    }

    return(sc_client_lookup)
  }
