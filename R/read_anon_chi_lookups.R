#' Read in the CHI to Anon Lookup
#'
#' @description Reads in the lookup to convert CHI number to Anonymous code
#'
#' @return the chi to anon lookup
#' @export
#'
read_chi_to_anon <- function() {
  chi_to_anon_path <-
    fs::path("/conf/hscdiip/01-Source-linkage-files/CHI-to-Anon-lookup.zsav")

  chi_to_anon <- haven::read_sav(chi_to_anon_path)

  return(chi_to_anon)
}

#' Read the Anon to CHI lookup
#'
#' @description Reads in the lookup to Anonymous code to CHI number
#'
#' @return the anon to chi lookup
#' @export
#'
read_anon_to_chi <- function() {
  anon_to_chi_path <-
    fs::path("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.zsav")

  anon_to_chi <- haven::read_sav(anon_to_chi_path)

  return(anon_to_chi)
}
