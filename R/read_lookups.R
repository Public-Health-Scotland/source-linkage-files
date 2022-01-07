#' Get the path to the lookups directory
#'
#' @return the Lookups directory path as a [fs::path]
#' @export
get_lookups_dir <- function() {
  fs::path("/conf/linkage/output/lookups/Unicode")
}


#' Read the locality file
#'
#' @param file - the file name of the locality file
#'
#' @return The data read using `readr::read_rds`
#' @export
read_locality_file <- function(file) {
  locality_path <- fs::path(get_lookups_dir(), "Geography", "HSCP Locality", file)

  # If given a sav extension (or other), swap it for rds
  locality_path <- fs::path_ext_set(locality_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(locality_path, "read")) {
    rlang::abort(message = "Couldn't read the locality file")
  }

  return(readr::read_rds(locality_path))
}


#' Read the Scottish Postcode Directory file
#'
#' @param file - the file name of the spd file
#'
#' @return The data read using `readr::read_rds`
#' @export
read_spd_file <- function(file) {
  spd_path <- fs::path(get_lookups_dir(), "Geography", "Scottish Postcode Directory", file)

  # If given a sav extension (or other), swap it for rds
  spd_path <- fs::path_ext_set(spd_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(spd_path, "read")) {
    rlang::abort(message = "Couldn't read the spd file")
  }

  return(readr::read_rds(spd_path))
}


#' Read the Scottish Index for Multiple Deprivation (SIMD)
#' @param file - the file name of the simd file
#'
#' @return The data read using `readr::read_rds`
#' @export
read_simd_file <- function(file) {
  simd_path <- fs::path(get_lookups_dir(), "Deprivation", file)

  # If given a sav extension (or other), swap it for rds
  simd_path <- fs::path_ext_set(simd_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(simd_path, "read")) {
    rlang::abort(message = "Couldn't read the simd file")
  }

  return(readr::read_rds(simd_path))
}


#' Read the Datazone populations
#' @param file - the file name of the datazone populations file
#'
#' @return The data read using `readr::read_rds`
#' @export
read_datazone_pop_file <- function(file) {
  datazone_pop_path <- fs::path(get_lookups_dir(), "Populations", "Estimates", file)

  # If given a sav extension (or other), swap it for rds
  datazone_pop_path <- fs::path_ext_set(datazone_pop_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(datazone_pop_path, "read")) {
    rlang::abort(message = "Couldn't read the datazone population file")
  }

  return(readr::read_rds(datazone_pop_path))
}
