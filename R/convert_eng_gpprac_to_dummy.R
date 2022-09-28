#' Convert GP Practice Codes to a Dummy Code
#'
#' @description Convert English GP practice codes to a dummy code
#'
#' @param gpprac A character vector containing the GP practice codes
#' @param dummy_code The dummy code to use. Default is 9995
#'
#'
#' @return An integer vector with only Scottish GP codes
#' @export
convert_eng_gpprac_to_dummy <- function(gpprac, dummy_code = 9995L) {
    gpprac <- dplyr::if_else(
        stringr::str_detect(gpprac, "[A-Z]"),
        dummy_code,
        suppressWarnings(readr::parse_integer(gpprac))
      )

  return(gpprac)
}
