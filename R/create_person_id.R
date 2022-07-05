#' Create the Person ID
#'
#' @description Creates the Person ID - using the sending location code and clients social care ID,
#' the default is Social Care which uses sending location and Social Care ID to compute the Person ID
#'
#' @param data the data containing the variables to compute the person id from
#' @param type the type of the ID
#'
#' @return The social care person id
#' @export
#'
#' @family id functions
create_person_id <- function(data, type = c("SC")) {
  if (missing(type)) {
    type <- "SC"
  }

  type <- match.arg(type)

  if (type == "SC") {
    dplyr::mutate(data, person_id = paste0(.data$sending_location, "-", .data$social_care_id))
  } else {
    data
  }
}
