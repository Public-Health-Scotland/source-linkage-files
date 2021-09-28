get_lookups_dir <- function() {
  fs::path("/conf/linkage/output/lookups/Unicode")
}


#' Read the locality file
#'
#' @param file - the file name of the locality file
#' @param ... optional arguments passed on to read_rds
#'
#' @return The data read using `readr::read_rds``
#' @export
#'
#' @examples
#' locality_file <- read_locality_file("HSCP Localities_DZ11_Lookup_20200825.rds")
read_locality_file <- function(file, ...) {
  locality_path <- fs::path(get_lookups_dir(), "Geography", "HSCP Locality", file)

  # If given a sav extension (or other), swap it for rds
  locality_path <- fs::path_ext_set(locality_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(locality_path, "read")) {
    rlang::abort(message = "Couldn't read the locality file")
  }

  return(readr::read_rds(locality_path, ...))
}
