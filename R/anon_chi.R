#' Convert anon_chi to CHI numbers
#'
#' @param anon_chi a character vector of anon_chi.
#'
#' @return a character vector of the corresponding CHI numbers.
#' @family anon_chi
convert_anon_chi_to_chi <- Vectorize(function(anon_chi) {
  openssl::base64_decode(anon_chi) %>%
    substr(2, 2) %>%
    paste0(collapse = "")
})

#' Convert CHI numbers to anon_chi
#'
#' @param chi a character vector of CHI numbers.
#'
#' @return a character vector of the corresponding anon_chi.
#' @family anon_chi
convert_chi_to_anon_chi <- Vectorize(function(chi) {
  if (!all(phsmethods::chi_check(chi) %in% c(
    "Valid CHI",
    "Missing (Blank)",
    "Missing (NA)"
  ))) {
    cli::cli_abort(
      c("There were bad CHI numbers according to {.help {.fun phsmethods::chi_check}}.",
        "i" = "{.param chi} must contain only valid or missing CHI numbers."
      )
    )
  }

  openssl::base64_encode(chi)
})
