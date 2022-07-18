#' Create the Person ID variable
#'
#' @description Creates the Person ID, this depends on the data set used
#'
#'  * Social Care - uses the `sending_location` code and the client's
#'  `social_care_id`
#'
#' @param data the data containing the variables to compute the person id from
#' @param type the dataset type to use to create the ID options are:
#'
#'  * 'SC' (Social Care)
#'
#' @return The data with the `person_id` variable added
#' @export
#'
#' @family id functions
create_person_id <- function(data, type = c("SC")) {
  type <- match.arg(type)

  if (type == "SC") {
    if (!all(c("sending_location", "social_care_id") %in% names(data))) {
      cli::cli_abort(message = c("The variables {.var sending_location} and
                                 {.var social_care_id} are both needed to create a
                                 Social Care person_id"))
    }
    dplyr::mutate(data, person_id = paste0(.data$sending_location, "-", .data$social_care_id))
  } else {
    data
  }
}
