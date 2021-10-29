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
read_chi_to_anon <- function() {
  chi_to_anon_path <- fs::path("/conf/hscdiip/01-Source-linkage-files/CHI-to-Anon-lookup.zsav")

  chi_to_anon <- haven::read_sav(chi_to_anon_path)

  return(chi_to_anon)
}

read_anon_to_chi <- function() {
  anon_to_chi_path <- fs::path("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav")

  anon_to_chi <- haven::read_sav(anon_to_chi_path)

  return(anon_to_chi)
}
