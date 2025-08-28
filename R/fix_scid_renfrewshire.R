#' Fix social care id in renfrewshire
#'
#' @param data social care extracts, ch, hc, sds, at, demog
#'
#' @return
#'
#' @examples fix_scid_renfrewshire(data)
fix_scid_renfrewshire <- function(data) {
  data <- data %>%
    dplyr::mutate(
      social_care_id = dplyr::if_else(
        sending_location == "350" & !grepl("PER", social_care_id),
        stringr::str_c("PER", social_care_id),
        social_care_id
      )
    )
  return(data)
}
