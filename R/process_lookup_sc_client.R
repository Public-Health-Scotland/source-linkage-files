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
             dplyr::select(c("sending_location", "social_care_id", "anon_chi", "extract_date", "consistent_quality")),
           write_to_disk = TRUE) {
    # Check if year is valid for sc_client
    if (!check_year_valid(year, "client")) {
      return(NULL)
    }

    # Match to demographics lookup to get CHI
    sc_client_demographics <- data %>%
      dplyr::right_join(
        sc_demographics,
        by = c("sending_location", "social_care_id")
      ) %>%
      # need period for the replace sc id with latest function
      dplyr::mutate(period = ifelse(!(is.na(.data$financial_quarter)),
        paste0(.data$financial_year, "Q", .data$financial_quarter),
        .data$financial_year
      )) %>%
      replace_sc_id_with_latest() %>%
      # remove cases with no data in client
      dplyr::filter(!(is.na(.data$financial_year))) %>%
      dplyr::select(-.data$latest_sc_id, -.data$period)

    client_clean <- sc_client_demographics %>%
      dplyr::group_by(.data$sending_location, .data$social_care_id, .data$anon_chi) %>%
      # summarise to take last submission
      dplyr::summarise(dplyr::across(
        c(
          "dementia",
          "mental_health_disorders",
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
            "day_care",
            "dementia",
            "mental_health_disorders",
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
            "type_of_housing"
          ),
          tidyr::replace_na, 9L
        )
      ) %>%
      # factor labels
      dplyr::mutate(
        dplyr::across(
          c(
            "living_alone",
            "support_from_unpaid_carer",
            "social_worker",
            "meals",
            "day_care",
            "dementia",
            "mental_health_disorders",
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
          levels = c(0L, 1L, 9L),
          labels = c("No", "Yes", "Not Known")
        ),
        type_of_housing = factor(.data$type_of_housing,
          levels = 1L:9L,
          labels = c(
            "Mainstream", # 1
            "Supported", # 2
            "Long Stay Care Home", # 3
            "Hospital or other medical establishment", # 4
            "Homeless", # 5
            "Penal Institutions", # 6
            "Not Known", # 7
            "Other", # 8
            "Not Known" # 9
          )
        )
      ) %>%
      # rename variables
      dplyr::rename_with(
        .cols = -c("sending_location", "social_care_id", "anon_chi"),
        .fn = ~ paste0("sc_", .x)
      )


    sc_client_lookup <- client_clean %>%
      # reorder
      dplyr::select(
        "anon_chi",
        "sending_location",
        "social_care_id",
        "sc_living_alone",
        "sc_support_from_unpaid_carer",
        "sc_social_worker",
        "sc_type_of_housing",
        "sc_meals",
        "sc_day_care",
        "sc_dementia",
        "sc_learning_disability",
        "sc_mental_health_disorders",
        "sc_physical_and_sensory_disability",
        "sc_drugs",
        "sc_alcohol",
        "sc_palliative_care",
        "sc_carer",
        "sc_elderly_frail",
        "sc_neurological_condition",
        "sc_autism",
        "sc_other_vulnerable_groups"
      ) %>%
      create_person_id() %>%
      select_linking_id()


    sc_client_lookup <-
      dplyr::mutate(sc_client_lookup,
        count_not_known = rowSums(
          dplyr::select(sc_client_lookup, tidyr::all_of(
            c(
              "sc_living_alone",
              "sc_support_from_unpaid_carer",
              "sc_social_worker",
              "sc_type_of_housing",
              "sc_meals",
              "sc_day_care",
              "sc_dementia",
              "sc_learning_disability",
              "sc_mental_health_disorders",
              "sc_physical_and_sensory_disability",
              "sc_drugs",
              "sc_alcohol",
              "sc_palliative_care",
              "sc_carer",
              "sc_elderly_frail",
              "sc_neurological_condition",
              "sc_autism",
              "sc_other_vulnerable_groups"
            )
          )) == "Not Known",
          na.rm = TRUE
        )
      ) %>%
      dplyr::arrange(.data$anon_chi, .data$count_not_known) %>%
      dplyr::distinct(.data$anon_chi, .keep_all = TRUE) %>%
      dplyr::select(-.data$sending_location, -.data$count_not_known)

    if (write_to_disk) {
      write_file(
        sc_client_lookup,
        get_sc_client_lookup_path(year, check_mode = "write"),
        group_id = 3206 # hscdiip owner
      )
    }

    return(sc_client_lookup)
  }
