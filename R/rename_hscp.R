#' Rename hscp where applicable for testing
#'
#' @param data processed data for testing e.g. acute
#'
#' @return data with correct hscp naming.
#' @export
#'
rename_hscp <- function (data) {

if ("hscp" %in% names(data)) {
  data <- data %>%
    dplyr::rename("hscp2018" = "hscp")
} else {
  data <- data
}

}
