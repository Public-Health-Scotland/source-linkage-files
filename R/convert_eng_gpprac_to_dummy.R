#' Convert GP Practice Codes to a Dummy Code
#'
#' @description Convert English GP practice codes to a dummy code
#'
#' @param data a [tibble][tibble::tibble-package]
#' @param gpprac The column containing the GP practice codes
#' @param dummy_code The dummy code to use. Default is 9995
#'
#' @importFrom rlang := .data
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
convert_eng_gpprac_to_dummy <- function(data, gpprac, dummy_code = 9995L) {
  data <- data %>%
    dplyr::mutate(
      {{ gpprac }} := dplyr::if_else(
        stringr::str_detect({{ gpprac }}, "[A-Z]"),
        dummy_code,
        suppressWarnings(readr::parse_integer({{ gpprac }}))
      )
    )

  return(data)
}
