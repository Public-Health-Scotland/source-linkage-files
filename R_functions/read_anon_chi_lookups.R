#' Functions for reading the Anon_chi lookups
#'
#' @param chi_to_anon, anon_to_chi - Locations of existing Anon_chi lookups
#' @param
#'
#' @return
#' @export
#'
#' @examples
#' chi_to_anon <- chi_to_anon()

chi_to_anon <- function () {
  "/conf/hscdiip/01-Source-linkage-files/CHI-to-Anon-lookup.zsav"
}

anon_to_chi <- function() {
  "/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav"
}
