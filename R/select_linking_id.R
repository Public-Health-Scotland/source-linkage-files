#' Select linking ID
#' Set linking_id as anon_chi if available otherwise social_care_id with
#' sending location.
#'
#' @param data social care data with anon_chi and social_care_id with sending_location
#'
#' @returns social care data with anon_chi and social_care_id with sending_location
select_linking_id <- function(data) {
  data %>% dplyr::mutate(linking_id = dplyr::if_else(
    is.na(.data$anon_chi),
    paste0("SCID", .data$sending_location, "-", .data$social_care_id),
    .data$anon_chi
  ))
}
