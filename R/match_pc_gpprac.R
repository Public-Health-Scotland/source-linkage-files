#' Fill postcode and GP practice geographies
#'
#' @description First improve the completion if possible
#' then use the lookups to match on additional variables.
#'
#' @param data the SLF
#'
#' @return a [tibble][tibble::tibble-package] of the SLF with improved
#' Postcode and GP Practice details.
#' @export
fill_geographies <- function(data) {
  check_variables_exist(data, c(
    "chi",
    "postcode",
    "hbrescode",
    "hscp",
    "lca",
    "datazone",
    "hbpraccode",
    "hbtreatcode",
    "gpprac",
    "hbpraccode"
  ))

  data %>%
    fill_postcode_geogs() %>%
    correct_gpprac_geographies()
}

fill_postcode_geogs <- function(data) {
  spd <- readr::read_rds(get_slf_postcode_path())

  filled_postcodes <- data %>%
    dplyr::mutate(postcode = phsmethods::format_postcode("postcode")) %>%
    fill_values(dplyr::select(spd, "postcode"), "postcode")

  data_geographies <- dplyr::left_join(
    filled_postcodes,
    spd,
    by = "postcode",
    suffix = c("_old", "")
  )

  filled_geographies <- data_geographies %>%
    dplyr::mutate(
      # Recode Health Board codes to consistent boundaries
      dplyr::across(
        c("hbrescode", "hbpraccode", "hbtreatcode"), ~ recode_health_boards(.x)
      ),
      # Recode HSCP codes to consistent boundaries
      hscp2018 = recode_hscp(.data$hscp2018)
    ) %>%
    cascade_geographies() %>%
    dplyr::mutate(
      hbrescode = dplyr::coalesce(.data$hb2018, .data$hbrescode),
      hscp = dplyr::coalesce(.data$hscp2018, .data$hscp),
      lca = dplyr::coalesce(.data$lca, .data$lca_old)
    ) %>%
    dplyr::select(-"hb2018", -"hscp2018", -"lca_old")

  return(filled_geographies)
}

correct_gpprac_geographies <- function(data) {
  gpprac_ref <- readr::read_rds(get_slf_gpprac_path()) %>%
    dplyr::select(c("gpprac", "cluster", "hbpraccode"))

  filled_gpprac <- fill_values(data, dplyr::select(gpprac_ref, "gpprac"), "gpprac")

  data_geographies <- dplyr::left_join(
    filled_gpprac,
    gpprac_ref,
    by = "gpprac",
    suffix = c("_old", "")
  )

  filled_geographies <- data_geographies %>%
    dplyr::mutate(
      hbpraccode = dplyr::coalesce(.data$hbpraccode, .data$hbpraccode_old)
    ) %>%
    dplyr::select(-"hbpraccode_old")

  return(filled_geographies)
}

fill_values <- function(data, lookup, type = c("postcode", "gpprac")) {
  type <- match.arg(type)

  data_values_flagged <- data %>%
    flag_matching_data(
      lookup = lookup,
      type = type
    )

  data_values_filled <- data_values_flagged %>%
    fill_data_from_chi(type = type) %>%
    # Remove unnecessary variables
    dplyr::select(-c("all_match", "lookup_match"))


  return(data_values_filled)
}

flag_matching_data <- function(data, lookup, type = c("postcode", "gpprac")) {
  type <- match.arg(type)

  flagged_data <- dplyr::bind_rows(
    # First, get all the rows that do match,
    # and give the variable postcode_match = 1
    dplyr::semi_join(data, lookup, by = type) %>%
      dplyr::mutate(lookup_match = TRUE),
    # For the rows that do not match, give value of postcode_match = 0
    dplyr::anti_join(data, lookup, by = type) %>%
      dplyr::mutate(lookup_match = FALSE)
  ) %>%
    dplyr::group_by(.data$chi) %>%
    dplyr::mutate(all_match = mean(.data$lookup_match)) %>%
    dplyr::ungroup()

  return(flagged_data)
}


fill_data_from_chi <- function(data, type = c("postcode", "gpprac")) {
  type <- match.arg(type)

  potentially_fixable <- data %>%
    # If the CHI isn't missing and all_match isn't exactly 0 or 1,
    # we can potentially fill the postcodes for that CHI
    dplyr::filter(!is_missing(.data$chi) & !(.data$all_match %in% c(0L, 1L)))

  no_change <- data %>%
    dplyr::filter(is_missing(.data$chi) | .data$all_match %in% c(0L, 1L))

  fixed <- potentially_fixable %>%
    dplyr::group_by(.data$chi) %>%
    # Sort by episode dates so that the fill will use the 'nearest in time' postcode
    dplyr::arrange(
      .data$keydate1_dateformat,
      .data$keydate2_dateformat,
      .by_group = TRUE
    ) %>%
    dplyr::mutate(
      {{ type }} := ifelse(.data$lookup_match, .data[[type]], NA),
      {{ type }} := dplyr::na_if(.data[[type]], "NK010AA"),
      {{ type }} := dplyr::na_if(.data[[type]], 99999L)
    ) %>%
    # Now we can fill the variables for these CHIs
    tidyr::fill({{ type }}, .direction = "downup") %>%
    dplyr::ungroup()

  fixed_data <- dplyr::bind_rows(
    no_change,
    fixed
  )

  return(fixed_data)
}
