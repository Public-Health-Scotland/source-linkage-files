#' Get the Social Care Person ID
#'
#' @param type the type of the ID
#'
#' @return The social care person id
#' @export
#' @family file path functions
create_person_id <- function(data, type = c("SC")) {
  if (type == "SC") {
    mutate(data, person_id = paste0(sending_location, "-", social_care_id))
  } else {
    data
  }
}
