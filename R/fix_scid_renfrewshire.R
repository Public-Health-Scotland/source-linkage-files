#' Fix social care id in renfrewshire
#'
#' @param data social care extracts, ch, hc, sds, at, demog
#'
#' @return social care data with scid in renfrewshire fixed.
fix_scid_renfrewshire <- function(data) {
  data <- data %>%
    dplyr::mutate(
      social_care_id = dplyr::if_else(
        .data$sending_location == "350" & !grepl("PER", .data$social_care_id),
        stringr::str_c("PER", .data$social_care_id),
        .data$social_care_id
      )
    )
  return(data)
}
