#' Read the CHI to Anon lookup
#'
#' @return the chi to anon lookup
#' @export
#'
#' @examples
read_chi_to_anon <- function() {
  chi_to_anon_path <- fs::path("/conf/hscdiip/01-Source-linkage-files/CHI-to-Anon-lookup.zsav")

  chi_to_anon <- haven::read_sav(chi_to_anon_path)

  return(chi_to_anon)
}

#' Read the Anon to CHI lookup
#'
#' @return the anon to chi lookup
#' @export
#'
#' @examples
read_anon_to_chi <- function() {
  anon_to_chi_path <- fs::path("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav")

  anon_to_chi <- haven::read_sav(anon_to_chi_path)

  return(anon_to_chi)
}
