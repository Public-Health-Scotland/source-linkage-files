#' Fix the West Dunbartonshire duplicates - Homelessness
#'
#' @description Takes the homelessness data and filters out
#' the West Dun duplicates where one has an app_number e.g.
#' "ABC123" and another has "00ABC123". It first modifies IDs
#' of this type and then filters where this 'creates' a duplicate.
#'
#' @param data the homelessness data - It must contain the
#' `sending_local_authority_name`, `application_reference_number`,
#' `client_unique_identifier`, `assessment_decision_date` and
#' `case_closed_date`.
#'
#' @return The fixed data
#' @export
#'
#' @seealso process_homelessness_extract
fix_west_dun_duplicates <- function(data) {
  west_dun_fixed <- data %>%
    dplyr::filter(.data$sending_local_authority_name == "West Dunbartonshire") %>%
    # Remove the leading zeros
    dplyr::mutate(dplyr::across(
      c("application_reference_number", "client_unique_identifier"),
      ~ stringr::str_remove(.x, "^00")
    )) %>%
    # Sort so the latest case closed date is at the top
    dplyr::arrange(dplyr::desc(.data$case_closed_date)) %>%
    # Keep only the first record for app_ref, client_id, decision_date.
    dplyr::distinct(.data$application_reference_number, .data$client_unique_identifier, .data$assessment_decision_date,
      .keep_all = TRUE
    )

  fixed_data <- dplyr::bind_rows(
    data %>%
      dplyr::filter(.data$sending_local_authority_name != "West Dunbartonshire"),
    west_dun_fixed
  )

  return(fixed_data)
}


#' Fix the East Ayrshire duplicates - Homelessness
#'
#' @description Takes the homelessness data and filters out
#' the East Ayrshire duplicates where one has an app_number e.g.
#' "ABC12345" and another has "ABC/12/345". It first modifies IDs
#' of this type and then filters where this 'creates' a duplicate.
#' The IDs with the `/` are more common so we add these rather than
#' remove them.
#'
#' @param data the homelessness data - It must contain the
#' `sending_local_authority_name`, `application_reference_number`,
#' `client_unique_identifier`, `assessment_decision_date` and
#' `case_closed_date`.
#'
#' @return The fixed data
#' @export
#'
#' @seealso process_homelessness_extract
fix_east_ayrshire_duplicates <- function(data) {
  east_ayrshire_fixed <- data %>%
    dplyr::filter(.data$sending_local_authority_name == "East Ayrshire") %>%
    # Remove the leading zeros
    dplyr::mutate(dplyr::across(
      c("application_reference_number", "client_unique_identifier"),
      ~ stringr::str_replace(.x, "^([A-Z]{2,3})([0-9]{2})(.+?)$", "\\1/\\2/\\3")
    )) %>%
    # Sort so the latest case closed date is at the top
    dplyr::arrange(dplyr::desc(.data$case_closed_date)) %>%
    # Keep only the first record for app_ref, client_id, decision_date.
    dplyr::distinct(.data$application_reference_number, .data$client_unique_identifier, .data$assessment_decision_date,
      .keep_all = TRUE
    )

  fixed_data <- dplyr::bind_rows(
    data %>%
      dplyr::filter(.data$sending_local_authority_name != "East Ayrshire"),
    east_ayrshire_fixed
  )
}
