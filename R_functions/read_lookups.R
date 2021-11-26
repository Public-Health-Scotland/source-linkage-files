#General lookup directory file path for accessing:
    #Locality file
    #Scottish postcode directory file
    #Scottish Index for multiple deprivation (SIMD) file
    #Datazone populations
get_lookups_dir <- function() {
  fs::path("/conf/linkage/output/lookups/Unicode")
}


###############################
#' Read the locality file
#'
#' @param file - the file name of the locality file
#'
#' @return The data read using `readr::read_rds``
#' @export
#'
#' @examples
#' locality_file <- read_locality_file("HSCP Localities_DZ11_Lookup_20200825.rds")
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


###############################
#'Read the Scottish Postcode Directory file
#' @param file - the file name of the spd file
#' @param ... optional arguments passed on to read_rds
#'
#' @return The data read using `readr::read_rds``
#' @export
#'
#' @examples
#'spd_file <- read_spd_file("Scottish_Postcode_Directory_2021_1.rds")
read_spd_file <- function(file, ...) {
  spd_path <- fs::path(get_lookups_dir(), "Geography", "Scottish Postcode Directory", file)

  # If given a sav extension (or other), swap it for rds
  spd_path <- fs::path_ext_set(spd_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(spd_path, "read")) {
    rlang::abort(message = "Couldn't read the spd file")
  }

  return(readr::read_rds(spd_path, ...))
}


###############################
#'Read the Scottish Index for Multiple Deprivation (SIMD)
#' @param file - the file name of the simd file
#' @param ... optional arguments passed on to read_rds
#'
#' @return The data read using `readr::read_rds``
#' @export
#'
#' @examples
#'simd_file <- read_simd_file("postcode_2021_1_simd2020v2.rds")
read_simd_file <- function(file, ...) {
  simd_path <- fs::path(get_lookups_dir(), "Deprivation", file)

  # If given a sav extension (or other), swap it for rds
  simd_path <- fs::path_ext_set(simd_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(simd_path, "read")) {
    rlang::abort(message = "Couldn't read the simd file")
  }

  return(readr::read_rds(simd_path, ...))
}


###############################
#'Read the Datazone populations
#' @param file - the file name of the datazone populations file
#' @param ... optional arguments passed on to read_rds
#'
#' @return The data read using `readr::read_rds``
#' @export
#'
#' @examples
#'datazone_pop_file <- read_datazone_pop_file("DataZone2011_pop_est_2011_2019.rds")
read_datazone_pop_file <- function(file, ...) {
  datazone_pop_path <- fs::path(get_lookups_dir(), "Populations", "Estimates", file)

  # If given a sav extension (or other), swap it for rds
  datazone_pop_path <- fs::path_ext_set(datazone_pop_path, "rds")

  # Check if the file exists and we can read it
  if (!fs::file_access(datazone_pop_path, "read")) {
    rlang::abort(message = "Couldn't read the datazone population file")
  }

  return(readr::read_rds(datazone_pop_path, ...))
}
